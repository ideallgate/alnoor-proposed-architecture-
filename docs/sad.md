# Software Architecture Document: Noor in the Prophetic Sunnah

Status: skeleton. Sections fill in as each chunk is agreed. Decisions are recorded in [docs/adr](adr/README.md).

## 1. Introduction and goals
Scope from Annex Section 1. Capacity targets from Section 18: 10,000 registered users, 1,500 concurrent sessions at peak, 1,500+ hours of audio, 2 TB initial storage; API p95 under 500 ms, hadith screen under 1 s, search under 1 s, availability 99.5% monthly.

## 2. Constraints
Business and delivery rules that shape the design: the functional scope (Sections 1-16), capacity and quality targets (Section 18), the approval cycle and versioning rules (Sections 3, 15), security and privacy (Section 20), the 5-month schedule, the 12-month warranty, code in First Party repositories from day one, and handover without dependence on the Executor (Sections 24, 26).

Technology is the Executor's selection, recorded in the decisions below. Where it differs from the technology list in Annex Section 17, it appears in the deviation register.

### Deviation register (Annex Section 17)
| Annex names | Our selection | Decision | First Party confirmation |
|---|---|---|---|
| Backend: Laravel | Node.js + Express, TypeScript | [ADR-001](adr/ADR-001-backend-framework.md), [ADR-009](adr/ADR-009-express-vs-nestjs.md) | To be recorded |
| Admin dashboard: Vue 3 | React + TypeScript | [ADR-011](adr/ADR-011-admin-dashboard-react.md) | To be recorded |
| Queues: Laravel Queues or equivalent | pg-boss on PostgreSQL (Redis for cache only) | [ADR-012](adr/ADR-012-background-jobs.md) | To be recorded |

## 3. Context and scope (C4 level 1)
See [C4 level 1: system context](c4/01-context.md).

## 4. Solution strategy
| Area | Decision |
|---|---|
| Backend framework | [ADR-001](adr/ADR-001-backend-framework.md) |
| Database | [ADR-002](adr/ADR-002-database-postgresql.md) |
| Data access and migrations (Prisma) | [ADR-003](adr/ADR-003-data-access-and-migrations.md) |
| Express with hexagonal modules, not NestJS | [ADR-009](adr/ADR-009-express-vs-nestjs.md) |
| Modular monolith with extractable modules | [ADR-010](adr/ADR-010-modular-monolith.md) |
| Admin dashboard: React | [ADR-011](adr/ADR-011-admin-dashboard-react.md) |
| Background jobs: pg-boss on PostgreSQL | [ADR-012](adr/ADR-012-background-jobs.md) |
| Arabic search engine: OpenSearch | [ADR-013](adr/ADR-013-arabic-search.md) |
| Hosting: Ubuntu hosts, Docker Compose first, Kubernetes later | [ADR-015](adr/ADR-015-hosting-and-infrastructure.md) |
| Radio Noor: scheduled core, in-app baseline, optional live stream | [ADR-014](adr/ADR-014-radio-noor.md) |
| Content versioning | [ADR-004](adr/ADR-004-content-versioning.md) |
| Text anchors | [ADR-005](adr/ADR-005-text-anchors.md) |
| Classification trees | [ADR-006](adr/ADR-006-classification-trees.md) |
| Permissions | [ADR-007](adr/ADR-007-permission-model.md) |
| API contract | [ADR-008](adr/ADR-008-api-contract.md) |

## 5. Building blocks (C4 levels 2 and 3)
- [C4 level 2: containers](c4/02-containers.md)
- [C4 level 3: API components](c4/03-api-components.md)

Diagrams are Mermaid, rendered by GitHub. Level 3 covers the API only; the workers and the admin dashboard get their own level 3 when their designs are detailed.

## 6. Runtime views
Planned: publish a hadith through the approval cycle; play audio with synced text; radio now-playing.

## 7. Deployment view
Ubuntu LTS hosts running Docker Compose; separate application, worker, database and search hosts; object storage and CDN; backups in a separate location. Provider and region are set with the First Party. See [ADR-015](adr/ADR-015-hosting-and-infrastructure.md).

## 8. Cross-cutting concepts
_Security, observability, backup, versioning. Pending chunk 7._

## 9. Quality requirements
_Pending._

## 10. Risks and open points
- ADR-001 needs the First Party's written approval.
- Benchmark evidence comes from a single laptop; production-like performance tests are required before acceptance. The search benchmark is incomplete (no reversed-order pass, reduced PostgreSQL run, Meilisearch 50x not finished); see [ADR-013](adr/ADR-013-arabic-search.md).
- The search benchmark corpus is a public dataset with unverified redistribution rights. We need the First Party's real sample corpus, query list and agreed data volume to re-check the search decision.
- Provider, country and region, and the data-residency position under PDPL, need the First Party's decision ([ADR-015](adr/ADR-015-hosting-and-infrastructure.md)).
- A single host per role does not give automatic failover for the 99.5% target; it relies on fast rebuild and restore, shown in the restore and performance tests ([ADR-015](adr/ADR-015-hosting-and-infrastructure.md)).
- Arabic search ranking and the ta marbuta/ha rule need review and approval by the First Party's scholars ([ADR-013](adr/ADR-013-arabic-search.md)). This is a dependency for Phase 2 acceptance and should be scheduled early.

## 11. Glossary
Hadith, riwaya (narration), rawi (narrator), gharib al-hadith (rare vocabulary), sharh (explanation), tashkeel (diacritics), wird (daily portion).
