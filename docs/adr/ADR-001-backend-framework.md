# ADR-001: Backend framework: Node.js + Express vs Laravel with Octane

- **Status:** Proposed (requires the First Party's written approval under Annex Section 17)
- **Annex reference:** 17 (approved technologies), 18 (capacity), 19 (isolation of heavy tasks), 23 (5-month schedule), 33 (12-month warranty)
- **Type:** Locked once approved. This decision gates the rest.

> **Stub.** The evidence below is summarised from the benchmark kit and verification reports. The full options table and wording are to be finalised in the next session.

## Context
The annex names Laravel for the backend. Section 17 allows alternatives with written approval. We propose Node.js + Express + PostgreSQL (TypeScript). Capacity targets: 1,500 concurrent sessions at peak, API p95 under 500 ms, hadith screen under 1 s.

## Options considered
1. Laravel with Octane (current: Laravel 13), as named in the annex.
2. Node.js + Express (TypeScript).

## Evidence (same data, same SQL, same endpoints)
Native Apple M1 run (Node 22, Laravel 12, Octane on RoadRunner):

| | Node.js + Express | Laravel with Octane |
|---|---|---|
| Throughput at c=100 | about 10.7k req/s | about 2.2k req/s |
| Hadith p95 at c=100 / 500 / 1000 / 1500 | 13 / 67 / 125 / 178 ms | 75 / 336 / 691 / 920 ms |
| Average memory | 141 MB | 466 MB |
| Audio transcoding (same FFmpeg) | tie | tie |

Docker re-run (Node 24, Laravel 13.36.0, Octane 2.22.0): Octane reaches about 22-24% of Node.js + Express throughput at c=100, the same ratio as the native run. Details in the verification reports.

## Decision (proposed)
Use Node.js + Express with PostgreSQL. Both stacks meet the annex targets; the difference is hardware cost and responsiveness under load. Audio processing speed is a tie, because both call the same FFmpeg binary.

## Consequences
- Benefits: lower hosting cost, lower latency under load, one language (TypeScript) across web, admin, mobile and backend, and an existing auth/RBAC/admin foundation.
- Trade-off we accept: this departs from the annex's named backend, so it needs written approval and the client must trust our own benchmark.

## Known limits of the evidence
Single laptop, load generator shares the CPU, closed-loop ApacheBench traffic (far heavier than 1,500 real users), RoadRunner rather than Swoole. Compare the stacks with each other, not as production figures. Performance is re-tested before final acceptance, as Section 18 requires.
