# ADR-006: Classification trees

- **Status:** Accepted (Executor decision)
- **Annex reference:** 2.9
- **Type:** Open, low risk

## Context
Topics and classifications can be hierarchical. Trees are small (thousands of nodes) and rarely edited.

## Options considered
| | Adjacency list + recursive CTE | `ltree` path | Closure table | Nested sets |
|---|---|---|---|---|
| Simplicity | Highest | Medium | Lower | Lower |
| Read speed on subtrees | Good at this size | Very good | Very good | Very good |
| Editing and moving nodes | Easy | Moderate | Moderate | Painful |
| Extra setup | None | Extension | Extra table | None |

## Decision
Adjacency list with recursive CTEs. We can move to `ltree` later without changing the API.

## Consequences
- Trade-off we accept: slower than the alternatives at very large scale, which is not our case.
