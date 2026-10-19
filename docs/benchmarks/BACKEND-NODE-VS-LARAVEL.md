# Backend benchmark: Node.js + Express vs Laravel with Octane

Evidence for [ADR-001](../adr/ADR-001-backend-framework.md). Two runs of the same kit: an original native run on macOS (Node 22, Laravel 12) and a Docker re-run (Node 24, Laravel 13) that reproduced the ranking. The kits, with their reference results, are in `benchmarks/kits/` (`backend-node22-laravel12-kit.zip`, `backend-node24-laravel13-kit.zip`). The verification of both kits is summarized below.

## What was compared
Three endpoints with the same PostgreSQL 16 data and the same SQL for every stack: `/health` (no database), `/radio/now` (2 queries) and `/hadith/:id` (a 3-table join with Arabic text). Load: ApacheBench, 20,000 requests per run, 5 runs per cell (median shown), concurrency 100 to 1,500.

| Stack | Configuration |
|---|---|
| node | Node.js (22 LTS native, 24 in Docker), Express, `pg` pool of 10, one process, production mode |
| node-cluster | Same, 8 worker processes sharing a pool of 10 |
| php | Plain PHP-FPM 8.3 (no framework), 10 static children, OPcache, persistent PDO, nginx |
| laravel-fpm | Laravel (12 native, 13 in Docker), production optimized (config, route and event caches, raw queries, no Eloquent), PHP-FPM with 10 children, default non-persistent PDO |
| laravel-fpm-persistent | Same with persistent PDO |
| laravel-octane | Laravel with Octane on RoadRunner 2025.1.15, 10 workers, 500 requests per worker |

## Native run (Apple M1, macOS, Node 22, Laravel 12.69, 360 measured runs)
Median requests per second at concurrency 100 and 1,500 (successful rows only):

| Endpoint | Node c=100 | Laravel Octane c=100 | Octane / Node | Node c=1500 | Octane c=1500 | Octane / Node |
|---|---:|---:|---:|---:|---:|---:|
| `/radio/now` | 10,657 | 2,193 | 20.6% | 10,181 | 1,895 | 18.6% |
| `/hadith` | 9,684 | 2,173 | 22.4% | 9,200 | 1,954 | 21.2% |
| `/health` | 17,705 | 2,934 | 16.6% | 17,626 | 2,643 | 15.0% |

Hadith screen latency, p95 in ms:

| Concurrency | Node | Laravel Octane |
|---|---:|---:|
| 100 | 13 | 75 |
| 500 | 67 | 336 |
| 1,000 | 125 | 691 |
| 1,500 | 178 | 920 |

Memory (process RSS, average under load): Node about 142 MB, Laravel Octane about 466 MB. Both stacks completed 1,500 concurrent connections with zero errors. Audio transcoding with FFmpeg tied (about 130 s for both), and a Redis-backed queue run with 2 workers took about 149 s for both Node (BullMQ) and Laravel.

### How to read the other rows honestly
- **Plain PHP-FPM is not slow.** The `php` stack (no framework) reached 99% of Node on `/radio/now` and 129% on `/hadith` at c=100. The gap above is Laravel's framework and Octane overhead on this workload, not PHP itself.
- **Laravel on PHP-FPM at c=100 reached 7.5% of Node** (about 800 req/s), and 20% with persistent PDO, which is about the same as Octane.
- **Rows with errors are excluded.** At c=500 and above, the FPM stacks returned tens of thousands of HTTP 502 responses (for example 99,040 non-2xx out of 100,000 for Laravel FPM `/radio/now` at c=500), caused by the PHP-FPM socket backlog (128). Their high req/s numbers at those concurrencies are error responses and are not capacity. Only Node, Node cluster and Laravel Octane had zero errors at every concurrency.
- Node cluster (8 workers) reached about 96-130% of single-process Node on the database-backed endpoints, with higher memory (about 730 MB).

## Docker re-run (Node 24.22, Laravel 13.36, Octane 2.22, PostgreSQL 16.15)
Compose caps: runner 3 CPUs / 3 GiB, PostgreSQL 1 CPU / 1 GiB. Quick matrix, 60 rows, after the fix below: zero failed and zero non-2xx.

Median requests per second at c=100:

| Stack | `/health` | `/radio/now` | `/hadith/4242` |
|---|---:|---:|---:|
| Node | 22,406 | 5,428 | 5,657 |
| Node cluster | 20,168 | 2,894 | 3,866 |
| Laravel FPM | 1,396 | 178 | 171 |
| Laravel FPM, persistent PDO | 1,346 | 1,160 | 1,157 |
| Laravel Octane | 1,714 | 1,297 | 1,271 |

Octane reached about 24% (`/radio/now`) and 22% (`/hadith`) of Node, close to the native run's 21-22%. Absolute rates are lower in Docker because of the container CPU caps and the VM.

## Kit verification
Both kits built and passed parity (`PARITY OK`: hadith bodies byte-identical, radio shape and records match), seeded to the same checksum (2,096,700) and reseeded after `down -v`. Two defects were found and fixed in the kits, with `.orig` backups:
1. The PHP-FPM socket backlog was 128 while the container allowed 4,096, which produced 502s at c=500. It is now 4,096.
2. `run_queues.sh` assumed a `run/` directory already existed. It now creates it.

Notes from the verification: the quick run takes much longer than the README says (its soak loop finishes fixed 50,000-request batches); the Node 24 / Laravel 13 kit ships no Composer lockfile, so a rebuild may resolve newer Laravel 13.x versions; the Docker report's PostgreSQL resource columns and native-run wording are not valid for Docker runs; the full benchmark was not run in Docker.

## Limits
- One MacBook Pro (M1, 8 GB). The load generator, application and database share CPU, so absolute numbers are not production figures. Compare stacks with each other.
- Closed-loop ApacheBench traffic at c=1,500 is far heavier per user than 1,500 real users.
- Laravel was tuned for production but with raw SQL and no Eloquent, and with Octane on RoadRunner, not Swoole.
- Native and Docker runs used different Node and Laravel versions, so they are not a controlled version comparison.
- The three endpoints are simple. They say nothing about complex workloads.
- Performance is re-tested on a production-like environment before acceptance (Annex 18).

## What this does and does not show
Node.js + Express served about 4-5 times the requests per second of Laravel with Octane on database-backed endpoints and used about a third of the memory in this setup, with lower latency at high concurrency. Both met the annex targets in these tests. It does not show that Laravel cannot meet the targets, and it does not cover developer productivity, which is part of the reasoning in ADR-001.
