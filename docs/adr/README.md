# Architecture Decision Records

Prepared by IdeallCo Company.

> **Work in progress.** This is not a complete or final version. It is still being developed and some decisions are open. Content may change.

| ADR | Title | Annex | Status |
|---|---|---|---|
| [001](ADR-001-backend-framework.md) | Backend framework: Node.js + Express vs Laravel with Octane | 17, 18, 19 | Accepted by Executor; First Party approval not yet obtained |
| [002](ADR-002-database-postgresql.md) | Database: PostgreSQL | 17 | Accepted |
| [003](ADR-003-data-access-and-migrations.md) | Data access and migrations (Prisma) | 17, 24 | Accepted |
| [009](ADR-009-express-vs-nestjs.md) | Express with hexagonal modules, not NestJS | 17, 24, 26 | Accepted |
| [010](ADR-010-modular-monolith.md) | Modular monolith with extractable modules | 19, 17, 26 | Accepted |
| [011](ADR-011-admin-dashboard-react.md) | Admin dashboard: React + TypeScript | 14, 17 | Accepted |
| [012](ADR-012-background-jobs.md) | Background jobs: pg-boss on PostgreSQL | 17, 19, 7, 8, 11, 12, 14 | Accepted |
| [013](ADR-013-arabic-search.md) | Arabic search engine | 5, 17, 18, 23 | Accepted (OpenSearch; benchmark incomplete; scholar review pending) |
| [014](ADR-014-radio-noor.md) | Radio Noor: scheduled radio core, two delivery options | 12, 8, 17, 19 | Proposed (First Party chooses delivery option) |
| [015](ADR-015-hosting-and-infrastructure.md) | Hosting and infrastructure | 17, 18, 19, 20, 21, 26 | Accepted (provider and region open with the First Party; baseline Riyadh) |
| [004](ADR-004-content-versioning.md) | Content versioning and publishing | 15 | Accepted |
| [005](ADR-005-text-anchors.md) | Text anchors for gharib, narrators and sync | 2, 3, 7 | Accepted |
| [006](ADR-006-classification-trees.md) | Classification trees | 2 | Accepted |
| [007](ADR-007-permission-model.md) | Permission model | 15, 20 | Accepted |
| [008](ADR-008-api-contract.md) | API contract and OpenAPI generation | 17, 26 | Accepted |
| [016](ADR-016-mobile-apps.md) | Mobile apps: React Native | 4, 6, 9, 17, 18, 22 | Accepted (Phase 1 prototype must prove Arabic rendering, background audio, offline downloads) |
| [017](ADR-017-public-web.md) | Public web platform: Next.js | 13, 22, 25 | Accepted |
| [018](ADR-018-audio-storage-and-delivery.md) | Audio storage and delivery | 8, 9, 17, 18, 19, 20 | Accepted (CDN vendor open, see ADR-025) |
| [019](ADR-019-audio-pipeline-and-alignment.md) | Audio processing and audio-text alignment | 7, 8, 17, 28 | Accepted (automatic alignment: Proposed, evaluated in Phase 3) |
| [020](ADR-020-authentication-and-security.md) | Authentication and security controls | 4, 14, 20 | Accepted (sign-in methods open with the First Party) |
| [021](ADR-021-sync-and-api-versioning.md) | User data sync, offline behavior and API versioning | 3, 4, 9, 10, 18 | Accepted |
| [022](ADR-022-notifications.md) | Notifications | 10, 11, 34 | Accepted (email service and Firebase need First Party approval) |
| [023](ADR-023-observability-and-analytics.md) | Observability and analytics | 16, 17, 19, 20 | Accepted (GlitchTip as the Sentry equivalent needs First Party confirmation; no analytics tool at launch) |
| [024](ADR-024-repositories-ci-and-testing.md) | Repositories, CI/CD and testing | 17, 23, 24, 26 | Accepted (Git host with the First Party) |
| [025](ADR-025-edge-waf-and-cdn.md) | Edge: WAF for web and API, global CDN for audio | 17, 19, 20, 27, 28, 34 | Accepted (self-hosted WAF); CDN vendor open |

Use [template.md](template.md) for new records.
