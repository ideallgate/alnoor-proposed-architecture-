# ADR-008: API contract and OpenAPI generation

- **Status:** Proposed
- **Annex reference:** 17 (REST API, OpenAPI), 26.15
- **Type:** Open

## Context
OpenAPI documentation is a deliverable. The spec must not drift from the implementation.

## Options considered
| | Zod schemas generate validation and OpenAPI | Decorator code-first (NestJS, tsoa) | Hand-written spec |
|---|---|---|---|
| Drift risk | Low | Low | High |
| Fit with Express | Direct | Needs another framework or tooling | Direct |
| Handover | Plain TypeScript | Framework conventions | Spec and code separate |

## Decision (lean)
Schema-first with Zod: one definition drives request validation, response typing and the generated OpenAPI document.

## Consequences
- Trade-off we accept: generation tooling must be kept current.
