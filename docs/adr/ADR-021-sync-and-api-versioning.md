# ADR-021: User data sync, offline behavior and API versioning

- **Status:** Accepted (Executor decision)
- **Annex reference:** 3.7 (content without app releases), 4.6, 4.8, 9 (offline), 10.12, 13, 18 (last two major OS versions), 26.15
- **Type:** Open

## Context
Users can browse and use favorites, bookmarks, notes and last position without an account. After registration or login, this data must sync across devices and with the web. Plans and progress sync across devices. Content changes from the admin dashboard must reach the apps without a new release. Downloaded audio must handle content updates. Old app versions stay in use, so the API must evolve without breaking them.

## Options considered
| | Per-record last-write-wins with client IDs and a server change cursor | Conflict-free replicated data types (CRDTs) | Server-authoritative only (no offline edits) |
|---|---|---|---|
| Works offline and without an account | Yes | Yes | No |
| Complexity | Low to medium | High | Low |
| Fits the data (favorites, bookmarks, notes, progress) | Yes, with merge rules per type | More than needed | Does not meet the annex |

## Decision
**User data sync**
- Every user record (favorite, bookmark, note, progress, plan membership) gets an ID created on the device and a version stamp. Deletes are kept as tombstones.
- The device sends its changes since the last sync and receives changes since a server-issued cursor.
- Conflicts are resolved per record type: favorites and bookmarks by set union (a delete wins only if it is newer), notes by last write, reading progress by the furthest position, plan progress by the highest completed count.
- Data created before login is stored on the device and uploaded and merged on the first login.

**Content**
- Content is always read from the API (published pointer, ADR-004), so the admin can add books, chapters and hadiths without an app release.
- The apps keep a local cache with a content version. Downloaded audio stores the audio version it was downloaded with. When a clip has a new published version, the app marks the download as outdated and offers an update. Removal of withdrawn content applies on the next sync.

**API versioning**
- The API path carries a major version (`/v1`). Within a major version, changes only add fields or endpoints. Breaking changes need a new major version, with the old one kept until the apps that use it are below a threshold we agree with the First Party.
- Apps send their version in a header. The server can mark a minimum supported version and ask the app to update.
- The OpenAPI document is the contract (ADR-008). CI compares each change with the published contract and fails on a breaking change within a major version.

## Consequences
- Simple and predictable. Last-write-wins can lose a note edited on two offline devices at once. We accept that for notes and show it in the conflict rules, and we do not hide it.
- A cursor and tombstones need cleanup jobs (ADR-012) so tables do not grow without limit.
- Keeping an old API version alive costs effort, so the minimum supported app version is a decision made with the First Party at launch.
