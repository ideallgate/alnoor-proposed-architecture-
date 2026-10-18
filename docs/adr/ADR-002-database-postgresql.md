# ADR-002: Database: PostgreSQL

- **Status:** Proposed
- **Annex reference:** 17 (MySQL or PostgreSQL), 2, 3
- **Type:** Open (annex allows MySQL or PostgreSQL; this is our selection)

## Context
The content model is highly relational (hadith, narrations, narrators, explanations, sources) and annotated (gharib positions, sync points, trees, versions).

## Options considered
| | PostgreSQL | MySQL 8 |
|---|---|---|
| Tree queries | Recursive CTEs, optional `ltree` | Recursive CTEs |
| Structured fields (metadata, sync points) | JSONB with indexing | JSON, weaker indexing |
| Migrations | Transactional DDL: a failed migration rolls back | DDL is not transactional |
| Row-level security | Built in | Not available |
| Arabic full-text search | Not sufficient natively, so a dedicated engine is needed | Same limitation |

## Decision
PostgreSQL. Both meet the annex; PostgreSQL gives safer migrations and richer types for this model.

## Consequences
- Benefits: atomic migrations, JSONB, row-level security available if needed.
- Trade-off we accept: slightly more tuning knowledge than MySQL. Arabic search is handled by a separate engine (see the search ADR).
