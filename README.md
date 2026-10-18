# Noor in the Prophetic Sunnah: Architecture

Architecture documentation for the Noor platform (Dhurra Technology). It is built up chunk by chunk and reviewed as it grows.

## Contents

| Path | What it is |
|---|---|
| `docs/sad.md` | Software Architecture Document (arc42-style). C4 levels 1 to 3 live here as views. |
| `docs/adr/` | Architecture Decision Records, one decision per file. Index in `docs/adr/README.md`. |
| `docs/c4/` | C4 diagram sources (to be added at the end of the walkthrough). |

## Conventions

- Every significant choice gets an ADR: need, options compared, decision, trade-off accepted.
- Status is `Proposed`, `Accepted` or `Superseded by ADR-0xx`. Nothing is `Accepted` until the client or Hamed confirms.
- Each ADR cites the Technical Annex section it serves.
- Client-facing wording: always "Node.js + Express"; compare only against Laravel with Octane.

## Progress

- [x] Chunk 1: content model, approval cycle, versioning (ADR-002 to ADR-008)
- [ ] ADR-001: backend framework (stub, evidence summarised, to be finalised)
- [ ] Chunk 2: admin dashboard and editor
- [ ] Chunk 3: Arabic search
- [ ] Chunk 4: audio
- [ ] Chunk 5: apps and web
- [ ] Chunk 6: Radio Noor
- [ ] Chunk 7: cross-cutting concerns
- [ ] Chunk 8: technology table and C4 levels 1 to 3
