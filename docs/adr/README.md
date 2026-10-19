# Architecture Decision Records

| ADR | Title | Annex | Status |
|---|---|---|---|
| [001](ADR-001-backend-framework.md) | Backend framework: Node.js + Express vs Laravel with Octane | 17, 18, 19 | Accepted by Executor; First Party approval not yet obtained |
| [002](ADR-002-database-postgresql.md) | Database: PostgreSQL | 17 | Proposed |
| [003](ADR-003-data-access-and-migrations.md) | Data access and migrations (Prisma) | 17, 24 | Accepted |
| [009](ADR-009-express-vs-nestjs.md) | Express with hexagonal modules, not NestJS | 17, 24, 26 | Accepted |
| [010](ADR-010-modular-monolith.md) | Modular monolith with extractable modules | 19, 17, 26 | Accepted |
| [011](ADR-011-admin-dashboard-react.md) | Admin dashboard: React + TypeScript | 14, 17 | Accepted |
| [012](ADR-012-background-jobs.md) | Background jobs: pg-boss on PostgreSQL | 17, 19, 7, 8, 11, 12, 14 | Accepted |
| [013](ADR-013-arabic-search.md) | Arabic search engine | 5, 17, 18, 23 | Accepted (OpenSearch; benchmark incomplete; scholar review pending) |
| [014](ADR-014-radio-noor.md) | Radio Noor: scheduled radio core, two delivery options | 12, 8, 17, 19 | Proposed (First Party chooses delivery option) |
| [015](ADR-015-hosting-and-deployment.md) | Hosting and deployment | 17, 18, 19, 20, 21 | Accepted (deployment model); provider and region pending First Party |
| [015](ADR-015-hosting-and-infrastructure.md) | Hosting and infrastructure | 17, 18, 19, 20, 21, 26 | Accepted (provider and region open with the First Party) |
| [004](ADR-004-content-versioning.md) | Content versioning and publishing | 15 | Proposed |
| [005](ADR-005-text-anchors.md) | Text anchors for gharib, narrators and sync | 2, 3, 7 | Proposed |
| [006](ADR-006-classification-trees.md) | Classification trees | 2 | Proposed |
| [007](ADR-007-permission-model.md) | Permission model | 15, 20 | Proposed |
| [008](ADR-008-api-contract.md) | API contract and OpenAPI generation | 17, 26 | Proposed |

Use [template.md](template.md) for new records.
