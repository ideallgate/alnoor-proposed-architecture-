# ADR-010: Modular monolith with extractable modules

- **Status:** Accepted (Executor decision)
- **Annex reference:** 19.10 (heavy tasks isolated), 19.11 (scale without rebuilding), 17, 26
- **Type:** Open

## Context
Capacity target is 1,500 concurrent sessions within a 5-month schedule. Heavy work (audio processing) must be isolated from the main servers. The system may need to split later.

## Options considered
| | Modular monolith | Microservices from day one | Plain monolith, no boundaries |
|---|---|---|---|
| Fits the 5-month schedule | Yes | Risky: infrastructure and contracts up front | Fastest at first |
| Operations at target load | One app plus workers | Many services to deploy and monitor | Lowest |
| Scaling a hot spot later | Extract one module | Already separate | Costly refactor |
| Transactions across the content model | One database transaction | Distributed, hard | Simple |
| Handover | One repo, one deploy, clear module map | Many repos and contracts | Easy to run, hard to extend |

## Decision
Modular monolith with enforced boundaries, plus separate BullMQ workers for heavy tasks from day one.

Boundary rules:
1. A module exposes a small public interface (ports); other modules import only that.
2. Each module owns its tables; others read through the owner's interface.
3. Cross-module reactions go through an in-process event bus behind an interface, replaceable by a Redis queue.
4. Lint rules (for example dependency-cruiser or ESLint boundaries) fail CI on forbidden imports.
5. Audio processing, search indexing and the radio scheduler run as queue workers.

Likely modules: content, approval and versions, identity and permissions, library API, search, audio, plans and progress, notifications, radio, analytics and reports. Extraction order if needed: audio, search indexing, radio. Content and approval share transactions on purpose and are not split.

## Consequences
- Benefits: simple operations now, a clear path to split later.
- Trade-off we accept: the discipline is ours to maintain; lint and review only help if kept up.
