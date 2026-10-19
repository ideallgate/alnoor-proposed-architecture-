# Noor in the Prophetic Sunnah: Architecture

Architecture documentation for the Noor platform (Dhurra Technology). It is built up chunk by chunk and reviewed as it grows.

## Contents

| Path | What it is |
|---|---|
| `docs/sad.md` | Software Architecture Document (arc42-style). |
| `docs/adr/` | Architecture Decision Records, one decision per file. Index in `docs/adr/README.md`. |
| `docs/c4/` | C4 levels 1 to 3: Structurizr model (`workspace.dsl`) and Mermaid versions. |
| `docs/benchmarks/` | Benchmark reports referenced by the decisions (backend, queues, search). |

## Conventions

- Every significant decision has an ADR: need, options compared, decision, and the trade-off accepted.
- Status is `Proposed`, `Accepted` or `Superseded by ADR-0xx`. `Accepted` means the Executor has decided; items that need the First Party's approval or input say so in the status line and in SAD section 10.
- Each ADR cites the Technical Annex section it serves.
- Technology is the Executor's selection. Where it differs from Annex Section 17 it is listed in the deviation register in the SAD.

## Progress

- [x] Content model and approval cycle (ADR-002 to ADR-008)
- [x] Backend, modular monolith, admin, background jobs (ADR-001, 009 to 012)
- [x] Arabic search (ADR-013) and Radio Noor (ADR-014)
- [x] Hosting and deployment (ADR-015)
- [x] Mobile, web, audio, security, sync, notifications, observability, repositories (ADR-016 to 024)
- [x] SAD sections 1 to 11
- [x] C4 levels 1 to 3
- [ ] First Party confirmations recorded (deviation register, hosting provider and region, external services)
- [ ] Scholar approvals (search rule and ranking criteria)
