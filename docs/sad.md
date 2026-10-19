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
_To be added in chunk 8._

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
| Content versioning | [ADR-004](adr/ADR-004-content-versioning.md) |
| Text anchors | [ADR-005](adr/ADR-005-text-anchors.md) |
| Classification trees | [ADR-006](adr/ADR-006-classification-trees.md) |
| Permissions | [ADR-007](adr/ADR-007-permission-model.md) |
| API contract | [ADR-008](adr/ADR-008-api-contract.md) |

## 5. Building blocks (C4 levels 2 and 3)
_To be added in chunk 8._

## 6. Runtime views
Planned: publish a hadith through the approval cycle; play audio with synced text; radio now-playing.

## 7. Deployment view
_Section 19 infrastructure. Pending chunk 7._

## 8. Cross-cutting concepts
_Security, observability, backup, versioning. Pending chunk 7._

## 9. Quality requirements
_Pending._

## 10. Risks and open points
- ADR-001 needs the First Party's written approval.
- Benchmark evidence comes from a single laptop; production-like performance tests are required before acceptance.

## 11. Glossary
Hadith, riwaya (narration), rawi (narrator), gharib al-hadith (rare vocabulary), sharh (explanation), tashkeel (diacritics), wird (daily portion).
