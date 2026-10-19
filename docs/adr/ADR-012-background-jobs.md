# ADR-012: Background jobs: pg-boss on PostgreSQL

- **Status:** Accepted (Executor decision)
- **Annex reference:** 17 (Redis and queues), 19.10 (heavy tasks isolated), 8, 7, 11, 12, 14
- **Type:** Open (our technical selection)
- **Evidence:** [QUEUE-BENCHMARK.md](../benchmarks/QUEUE-BENCHMARK.md) (scenarios S1-S5) and [QUEUE-BENCHMARK-S6.md](../benchmarks/QUEUE-BENCHMARK-S6.md) (BullMQ with a transactional outbox)

## Context
Audio processing, audio-to-text alignment, search indexing, bulk import, report export, scheduled notifications and the radio schedule must run outside web requests, in isolated workers. Jobs need retries, status for the admin dashboard and, for search indexing, a guarantee that publishing content never leaves it unindexed (ADR-004).

Redis stays in the architecture for caching and rate limiting. A cache wants eviction; a queue must never lose data. Sharing one Redis for both forces a bad trade-off, which the benchmark confirmed.

Infrastructure tasks (backups, certificate renewal, log rotation) use systemd timers, not the application queue.

## Options considered
Measured in Docker on one Apple M1 laptop, 5 runs per cell, two passes with reversed order. Full tables and limits in the benchmark report.

| | BullMQ, dedicated Redis (AOF, noeviction) | BullMQ, shared Redis with the cache | pg-boss (PostgreSQL) | graphile-worker (PostgreSQL) |
|---|---|---|---|---|
| Throughput, 50,000 no-op jobs (N=10 / N=50) | about 7.1k / 7.5k jobs/s | about 8.9k / 9.4k jobs/s | about 1.3k / 4.3k jobs/s | about 2.5k / 1.7k jobs/s |
| Completion, 5,000 audio-like jobs + 10,000 notifications (N=50) | 22.2-22.4 s | 22.4-22.5 s | 24.5-24.6 s | 25.6-26.0 s |
| Hard kill with 20,000 waiting jobs | 0 lost | 20,000 lost (no persistence) | 0 lost | 0 lost |
| Cache pressure on the same Redis (256 MB) | not applicable | `allkeys-lru`: all 20,000 jobs evicted; `noeviction`: 55% of cache writes failed, new enqueues failed, worker often stalled | not applicable | not applicable |
| Content change committed without its reindex job (5,000 injected crashes, 100 SIGKILLs) | 5,000 of 5,000 and 100 of 100 | same | 0 | 0 |
| API req/s at c=100 while the queue ran (baseline about 18-19k) | no effect seen | no effect seen | no effect in pass 1, about 6% lower in pass 2 (not distinguishable from noise) | about 1-2% lower or no effect |
| Extra stateful service | A second Redis with persistence | None, but unsafe | None | None |

Errors across all throughput runs: 0 lost, 0 duplicate, 0 failed for every stack.

### BullMQ on a dedicated Redis with a transactional outbox (scenario S6)
The standard fix for BullMQ's commit-then-enqueue gap is an outbox table written in the same transaction as the content change, with a relay process that moves rows into the queue. Tested in Docker, 5 runs per cell, two passes with reversed order (results are the same in both):

| | BullMQ + outbox | pg-boss | graphile-worker |
|---|---|---|---|
| Crash before commit (5,000 injected) | 0 changes without a job | 0 | 0 |
| Producer killed right after commit (250 kills) | 0 changes without a job (relay caught up in about 17-19 ms) | 0 | 0 |
| Relay killed between enqueue and mark-sent | 0 lost; duplicates: every row executed twice when completed jobs are removed, 0 when completed jobs are kept (not tested for the other two, which have no relay step) | n/a | n/a |
| Total Redis data loss with 5,000 jobs waiting | 5,000 of 5,000 lost until a reconciliation step re-enqueued them (about 0.2 s to enqueue, about 1 s until all executed) | PostgreSQL process crash: 0 lost, no extra step | same |
| Publish cost per operation (excludes relay work) | about 0.4 ms | about 0.83 ms | about 0.67-0.74 ms |
| Latency from commit to job start (p99) | about 104-111 ms (set by the 100 ms poll) | about 2.0 s (default polling; opt-in notification not tested) | about 7-8 ms |

So BullMQ with an outbox matches the PostgreSQL queues on the crash cases tested, but it needs more around it: an outbox table with cleanup, an always-on relay process, a reconciliation procedure, idempotent handlers (it is at-least-once, and dedup by job id only works while the job still exists in Redis), a `done_at` write per job, monitoring of stuck rows, and the payload stored twice. The Redis-loss and PostgreSQL-crash rows are different failures and are not a like-for-like durability comparison.

## Decision
pg-boss on the application PostgreSQL, in its own schema with its own connection pool. Workers run as separate processes (ADR-010). Redis is used for cache and rate limiting only, so losing or evicting it never loses work.

Why PostgreSQL rather than BullMQ:
- **Transactional enqueue with no extra machinery.** The content change and its reindex job commit or roll back together. The plain "commit, then enqueue" pattern with BullMQ left every injected crash with a committed change and no job. An outbox fixes that for BullMQ (scenario S6), but adds the pieces listed above. Our reason is therefore simplicity and fewer failure modes, not that BullMQ cannot be made safe.
- **No second stateful service.** BullMQ is safe only on a dedicated Redis with persistence and no eviction, which is one more service to run, back up and monitor.
- **Throughput is sufficient.** The slowest PostgreSQL result (about 1.3k jobs/s) is far above Noor's expected workload (audio uploads, edits and notification batches).

Why pg-boss rather than graphile-worker: higher throughput at N=50 (about 4.3k vs 1.7k jobs/s, and graphile-worker got slower at higher concurrency for a reason not investigated), lower PostgreSQL CPU and memory in the mixed scenario at N=50, and the faster enqueue rate. Both lost nothing and left no job-less changes. graphile-worker's advantages are built-in LISTEN/NOTIFY wake-up and enqueueing with plain SQL.

## Consequences
- Benefits: no lost indexing jobs, one fewer service to operate, queue state covered by the normal database backup and restore.
- Trade-offs we accept:
  - BullMQ is faster on raw throughput in our tests (about 2-6x). If real volume ever approached those limits we would revisit this decision.
  - The queue adds load to the application database. In the throughput test, PostgreSQL CPU rose to 52-80% (against a one-core cap) for pg-boss. Mitigations: separate schema and pool, and the option to move the queue to its own PostgreSQL instance without changing application code.
  - Our pg-boss benchmark setup used batch fetching with `batchSize` equal to the concurrency, which departs from its defaults, and did not enable LISTEN/NOTIFY.
- pg-boss's default polling gives about 1.7 s from commit to job start. That is acceptable for search indexing, audio processing and notifications. If sub-second pickup ever matters, options are pg-boss's opt-in notification setting (not tested) or graphile-worker, which measured about 1 ms but was slower than pg-boss at higher concurrency and used more PostgreSQL CPU and memory in the mixed scenario. The choice between the two PostgreSQL queues is close, and both lost nothing.
- Notification jobs due at a set time go on their own queue, so a backlog of audio jobs cannot delay them. The benchmark used one shared queue, so its lateness figures are not evidence about timing.
- Limits of the evidence: one laptop, synthetic jobs, process kills and simulated crashes (not power loss), 5 runs per cell.
