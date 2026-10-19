# ADR-001: Backend framework: Node.js + Express vs Laravel with Octane

- **Status:** Accepted by the Executor. **First Party written approval under Annex Section 17: not yet obtained.** The annex requires prior written approval to replace the named backend technology.
- **Annex reference:** 17 (approved technologies), 18 (capacity), 19 (isolation of heavy tasks), 23 (5-month schedule), 33 (12-month warranty)
- **Type:** Open (our technical selection). This decision underpins the rest.

## Context
The annex names Laravel for the backend. Section 17 allows alternatives with written approval. We propose Node.js + Express + PostgreSQL (TypeScript). Capacity targets: 1,500 concurrent sessions at peak, API p95 under 500 ms, hadith screen under 1 s.

## Options considered
| | Node.js + Express (TypeScript) | Laravel with Octane (Laravel 13) |
|---|---|---|
| Named in the annex | No: needs the First Party's written approval | Yes |
| Language shared with web, admin and mobile | Yes (TypeScript) | No (PHP backend, TypeScript clients) |
| Throughput and memory in our benchmark | Higher throughput, lower memory (see Evidence) | Lower throughput, higher memory |
| Built-in features | Assembled from libraries we choose (ADR-003, 007, 008, 012) | Batteries included: queues, authentication, ORM, scheduler |
| Framework conventions and structure | Ours: hexagonal modules with lint-enforced boundaries (ADR-009, 010) | The framework's |
| Ecosystem and available developers | Large JavaScript and TypeScript pool | Large PHP and Laravel pool |
| Delivery inside the 5-month window | Existing Executor foundation for authentication, roles and admin (to be disclosed, Annex 27) | Built from the framework's starter pieces |
| Main risk | We own more architectural decisions and must keep the structure disciplined | Needs a long-running application server (Octane) tuned for load, and a second language across the system |

## Evidence (same data, same SQL, same endpoints)
Native Apple M1 run (Node 22, Laravel 12, Octane on RoadRunner):

| | Node.js + Express | Laravel with Octane |
|---|---|---|
| Throughput at c=100 | about 10.7k req/s | about 2.2k req/s |
| Hadith p95 at c=100 / 500 / 1000 / 1500 | 13 / 67 / 125 / 178 ms | 75 / 336 / 691 / 920 ms |
| Average memory | 141 MB | 466 MB |
| Audio transcoding (same FFmpeg) | tie | tie |

Docker re-run (Node 24, Laravel 13.36.0, Octane 2.22.0): Octane reaches about 22-24% of Node.js + Express throughput at c=100, the same ratio as the native run. Details in the verification reports.

## Decision
Use Node.js + Express with PostgreSQL (TypeScript). Both stacks meet the annex targets; the difference is hardware cost and responsiveness under load. Audio processing speed is a tie, because both call the same FFmpeg binary.

## Consequences
- Benefits: lower hosting cost, lower latency under load, one language (TypeScript) across web, admin, mobile and backend, and an existing auth/RBAC/admin foundation.
- Trade-off we accept: this departs from the annex's named backend, so it needs the First Party's written approval. The benchmark is ours, so the kit that produced it is available to the First Party to re-run.
- Components we already own (the authentication, roles and admin foundation) are disclosed in advance and licensed as Annex 27 requires, so they create no mandatory dependence on us.
- Laravel could deliver this project. The choice is about delivery speed, cost and one language across the system, not a claim that Laravel cannot meet the targets.

## Known limits of the evidence
Single laptop, load generator shares the CPU, closed-loop ApacheBench traffic (far heavier than 1,500 real users), RoadRunner rather than Swoole. Compare the stacks with each other, not as production figures. Performance is re-tested before final acceptance, as Section 18 requires.
