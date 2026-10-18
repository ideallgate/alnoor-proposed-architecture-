# Software Architecture Document: Noor in the Prophetic Sunnah

Status: skeleton. Sections fill in as each chunk is agreed. Decisions are recorded in [docs/adr](adr/README.md).

## 1. Introduction and goals
Scope from Annex Section 1. Capacity targets from Section 18: 10,000 registered users, 1,500 concurrent sessions at peak, 1,500+ hours of audio, 2 TB initial storage; API p95 under 500 ms, hadith screen under 1 s, search under 1 s, availability 99.5% monthly.

## 2. Constraints
Annex technology list (Section 17) unless approved otherwise; 5-month schedule; 12-month warranty; code in First Party repositories from day one; handover without dependence on the Executor (Sections 24, 26).

## 3. Context and scope (C4 level 1)
_To be added in chunk 8._

## 4. Solution strategy
| Area | Decision |
|---|---|
| Backend framework | [ADR-001](adr/ADR-001-backend-framework.md) |
| Database | [ADR-002](adr/ADR-002-database-postgresql.md) |
| Data access and migrations | [ADR-003](adr/ADR-003-data-access-and-migrations.md) |
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
