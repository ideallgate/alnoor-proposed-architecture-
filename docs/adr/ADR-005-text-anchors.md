# ADR-005: Text anchors for gharib, narrators and sync points

- **Status:** Accepted (Executor decision)
- **Annex reference:** 2.7, 3 (rules 3 and 4), 7, 14.3
- **Type:** Open, important

## Context
Gharib words and narrator mentions must link to fixed positions in the text, survive tashkeel and display changes, and support word-level audio sync where possible.

## Options considered
| | Character offsets | Token IDs | Inline markup in the text |
|---|---|---|---|
| Survives tashkeel or display changes | Fragile | Yes | Yes |
| Survives text edits | Breaks silently | Detectable per token | Mostly survives |
| Supports word-level sync | Needs extra mapping | Natural | Needs parsing |
| Keeps stored text clean | Yes | Yes | No, presentation mixed into data |
| Storage cost | Lowest | Higher (one entry per word) | Low |

## Decision
Store each narration as ordered tokens with stable IDs, with diacritics as token attributes. Gharib links, narrator links and sync points reference token IDs. Anchors belong to a text version, so a text edit can flag broken anchors and audio needing review (Section 7, point 5).

## Consequences
- Benefits: robust links, one mechanism for gharib, narrators and sync.
- Trade-off we accept: more rows, which is manageable at hadith-sized texts.
