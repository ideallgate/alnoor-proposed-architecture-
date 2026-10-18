# ADR-003: Data access and migrations

- **Status:** Proposed
- **Annex reference:** 17 (migrations in repository), 24 (migration files)
- **Type:** Open

## Context
The model needs recursive queries, JSONB operators and versioned tables. Migrations must live in the repository and be handed over cleanly.

## Options considered
| | Drizzle | Prisma | Kysely + SQL migrations | TypeORM |
|---|---|---|---|---|
| TypeScript types | Schema in TS, SQL-like queries | Generated client, very good | Excellent, SQL-shaped queries | Decorators, weaker inference |
| Recursive CTEs, JSONB operators | Raw SQL helpers, fine | Mostly raw SQL | Natural | Raw SQL |
| Migrations in repo | Yes, plain SQL files | Yes, plain SQL files | Separate tool needed | Yes |
| Weight and speed | Light | Heavier | Light | Medium |
| Learning curve for a new supplier | Low | Lowest | Medium | Medium |

## Decision (lean)
Drizzle, because SQL stays close at hand for trees, versions and JSONB.

## Consequences
- Trade-off we accept: a younger ecosystem than Prisma or TypeORM. Prisma is the safer handover choice if the client values familiarity over control.
