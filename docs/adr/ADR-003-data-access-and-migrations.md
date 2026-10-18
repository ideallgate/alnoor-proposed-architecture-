# ADR-003: Data access and migrations

- **Status:** Accepted (Executor decision)
- **Annex reference:** 17 (migrations in repository), 24 (migration files)
- **Type:** Open

## Context
The model needs recursive queries, JSONB operators and versioned tables. Migrations must live in the repository and be handed over cleanly.

## Options considered
| | Prisma | Drizzle | Kysely + SQL migrations | TypeORM |
|---|---|---|---|---|
| TypeScript types | Generated client, very good | Schema in TS, SQL-like queries | Excellent, SQL-shaped queries | Decorators, weaker inference |
| Recursive CTEs, JSONB operators | Raw SQL escape hatch | Raw SQL helpers, fine | Natural | Raw SQL |
| Migrations in repo | Yes, SQL migration files | Yes, plain SQL files | Separate tool needed | Yes |
| Weight and speed | Heavier | Light | Light | Medium |
| Learning curve for a new supplier | Lowest | Low | Medium | Medium |

## Decision
Prisma, as part of our proven stack. Recursive CTEs and other advanced queries use its raw-query support, kept inside the data-access layer.

## Consequences
- Benefits: lowest handover friction, strong generated types, migrations kept in the repository.
- Trade-off we accept: heavier than Drizzle or Kysely, and advanced SQL goes through raw queries.
