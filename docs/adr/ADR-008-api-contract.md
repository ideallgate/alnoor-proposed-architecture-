# ADR-008: API contract and OpenAPI generation

- **Status:** Accepted (Executor decision)
- **Annex reference:** 17 (REST API, OpenAPI), 26.15
- **Type:** Open

## Context
OpenAPI documentation is a deliverable. The spec must not drift from the implementation.

## Options considered
| | Zod schemas generate validation and OpenAPI | Decorator code-first (tsoa, or NestJS, which ADR-009 does not adopt) | Hand-written spec |
|---|---|---|---|
| Drift risk | Low | Low | High |
| Fit with Express | Direct | Needs another framework or tooling | Direct |
| Handover | Plain TypeScript | Framework conventions | Spec and code separate |

## Decision
Schema-first with Zod: one definition drives request validation, response typing and the generated OpenAPI document.

## Consequences
- The generated OpenAPI document is checked in CI against the published contract (ADR-021) and is a final deliverable (Annex 26.15). Types and the API client for web, admin and the mobile apps are generated from it.
- Trade-off we accept: generation tooling must be kept current.
