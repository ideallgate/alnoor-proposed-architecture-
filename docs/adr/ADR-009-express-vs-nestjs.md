# ADR-009: Backend structure: Express with hexagonal modules (not NestJS)

- **Status:** Accepted (Executor decision)
- **Annex reference:** 17, 24, 26
- **Type:** Open (internal implementation choice within the Node.js stack)

## Context
The client asked why we are not using NestJS. Our backend approach is Node.js + Express, TypeScript, Zod, OpenAPI/Swagger, lint-enforced boundaries, hexagonal design, spec-driven development, Prisma and PostgreSQL. We already have a working foundation and workflow on this stack.

## Options considered
| | Express + hexagonal modules | NestJS (Express adapter) | NestJS (Fastify adapter) |
|---|---|---|---|
| Structure | Our conventions, lint rules and review | Modules, DI and decorators by default | Same |
| Validation and OpenAPI | Zod generates both | `nestjs-zod` or class-validator, plus `@nestjs/swagger` | Same |
| ORM and database | Prisma + PostgreSQL | Same | Same |
| Fit with hexagonal design | Direct: domain code is plain TypeScript, Express is an adapter | Works, but DI and decorators tend to reach into domain code | Same |
| Spec-driven development | The spec (Zod, OpenAPI) drives the code | Decorators drive the spec | Same |
| Boilerplate and learning curve | Low | Higher | Higher |
| Fit with our existing foundation | Direct | Rebuild or wrap | Rebuild or wrap |

## Measured performance (Docker, Apple M1, same SQL and data, 5 runs, median)
- Database-backed endpoints (`/radio/now`, `/hadith/4242`) at c=100 and c=1000: both NestJS stacks within about ±3% of the Express stack, similar to run-to-run spread, in two passes with reversed order.
- `/health` (no database): NestJS on Fastify about 1.45-1.5x Express. This route measures framework overhead only. Part of the gap may come from the Express 5 vs 4 difference in the Nest adapter and from Fastify not sending an ETag.
- Memory: NestJS about 20 MB higher under load and 30-40 MB higher at idle.
- Limits: single laptop, load generator shares the CPU, closed-loop ab. Compare stacks with each other, not as production figures.

Performance is therefore not the reason for this choice.

## Decision
Express with hexagonal modules. Business logic is framework-independent TypeScript. The same core could be exposed through a NestJS adapter later at low cost.

## Consequences
- Benefits: reuses our proven foundation and workflow, minimal framework surface to maintain, domain code independent of any web framework.
- Trade-off we accept: structure depends on our lint rules, a module template and code review, whereas NestJS makes it the default.
