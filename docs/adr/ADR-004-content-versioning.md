# ADR-004: Content versioning and publishing

- **Status:** Proposed
- **Annex reference:** 15, 3 (rules 5 and 6), 14.5 (edit log)
- **Type:** Open, but central to the model

## Context
Content moves Draft, Under review, Approved or returned, Published. Editing published content creates a new version; the old one stays visible until the new one is approved and published. Only published content is shown to beneficiaries.

## Options considered
| | Row per version + published pointer | Single row + history snapshots | Event sourcing |
|---|---|---|---|
| Old version visible until new is published | Atomic pointer swap | Needs a separate draft copy | Needs projections |
| Comparison and restore | Easy | Easy | Possible, complex |
| Public API query simplicity | Join on the pointer | Simplest | Hardest |
| Fits the 5-month schedule | Yes | Yes | Risky |

## Decision
Row per version with a `published_version_id` pointer. The public API reads only through the pointer, and the "published only" rule is enforced in the data-access layer, not per endpoint.

The audit log (who changed what, before and after) is kept separate from content versions (approval cycle). They answer different questions.

## Consequences
- Benefits: the annex rule maps to one atomic operation; comparison and restore are simple.
- Trade-off we accept: more rows and one join on reads. Event sourcing would be overkill.
