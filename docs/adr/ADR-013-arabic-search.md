# ADR-013: Arabic search engine

- **Status:** Proposed. The engine decision is pending our bake-off. Ranking quality is pending review by the First Party's scholars (see Validation required).
- **Annex reference:** 5 (Arabic search), 17 (OpenSearch, Meilisearch or an approved technology), 18 (search under one second), 23 (Phase 2 acceptance: search from the app)
- **Type:** Open (our technical selection, from the options the annex lists)

## Context
Section 5 requires, at a minimum: vocalized and unvocalized search, hamza differences, alif maqsura and ya, ta marbuta and ha "per the approved search algorithm", the definite article, search in hadith texts, books and chapters, by narrator, by topic, in related scholarly information, suggestions while typing, match highlighting, ranking "by match accuracy and available scholarly criteria", and direct navigation to content. Response time target: under one second on the agreed data volume.

Two of these cannot be settled by engineering alone: the ta marbuta/ha rule is defined by an algorithm the First Party must approve, and the scholarly ranking criteria are theirs to define.

## Options considered
| | OpenSearch | Meilisearch | PostgreSQL full-text search |
|---|---|---|---|
| Named in the annex | Yes | Yes | No: needs First Party approval |
| Extra service to run | Yes | Yes | No |
| Arabic normalization (Section 5, items 1-5) | To be tested | To be tested | To be tested |
| Suggestions, highlighting, ranking control | To be tested | To be tested | To be tested |
| Latency at the agreed data volume | To be tested | To be tested | To be tested |
| Index updates on publish (ADR-012 jobs) | To be tested | To be tested | In the same database |

## Decision
Not yet taken. The bake-off compares the engines against the Section 5 requirements and records results here. PostgreSQL full-text search is tested as a baseline only.

## Validation required
What we can validate ourselves:
- Automatic recall for text variants: diacritics removed, hamza forms swapped, alif maqsura and ya swapped, ta marbuta and ha swapped, the definite article added or removed.
- Presence and behavior of suggestions, highlighting, filters and navigation.
- Latency and resource use at several corpus sizes, and index update time.

What needs the First Party's scholars (or scholars they nominate):
- Approval of the ta marbuta/ha handling and the "al-" rule (Section 5, items 4 and 5).
- Definition of the "scholarly criteria" for ranking (item 13): which signals count (for example hadith grade, source, book, exact match vs partial), and in what order.
- A judgment set of 20-30 real queries with the results scholars expect at the top.
- Review of the engine's ranking against that judgment set.

Until the second list is done, the accurate statement is that the chosen engine meets the technical requirements. It is not a claim that the ranking is scholarly-correct.

## Consequences
- The search engine choice is recorded with evidence, and the open items are visible to the client from the start instead of appearing at Phase 2 acceptance.
- The scholars' review is a dependency for Phase 2. It should be scheduled early, because ranking changes are cheap before launch and expensive after.
- Trade-off we accept: until scholars are involved, ranking is provisional.
