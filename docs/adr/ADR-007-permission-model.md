# ADR-007: Permission model

- **Status:** Accepted (Executor decision)
- **Annex reference:** 15 (roles, scoped permissions), 20 (RBAC at function and data level)
- **Type:** Open

## Context
Roles are Editor, Reviewer, Content manager and System admin. Permissions are scoped by book, section or content.

## Options considered
| | Hand-written policy layer | CASL | Casbin | OPA (external) |
|---|---|---|---|---|
| TypeScript-native | Yes | Yes | Adapters | No, separate service |
| Scope rules (role + book/section) | Fully flexible | Good fit | Good fit | Very flexible |
| Extra moving parts | None | A library | Library + policy files | A new service to run |
| Handover simplicity | Depends on our code quality | Familiar to many | Less familiar | Heavy for this project |

## Decision
CASL: declarative, testable rules, enforced in the data-access layer.

## Consequences
- Trade-off we accept: one more library to learn.
