# ADR-013: Arabic search engine

- **Status:** Proposed. Our recommendation is OpenSearch with a custom Arabic analyzer chain. Evidence is from an incomplete benchmark (see Limits of the evidence). The ta marbuta/ha rule and the ranking criteria are pending the First Party's scholars (see Validation required).
- **Annex reference:** 5 (Arabic search), 17 (OpenSearch, Meilisearch or an approved technology), 18 (search under one second), 23 (Phase 2 acceptance: search from the app)
- **Type:** Open (our technical selection, from the options the annex lists)
- **Evidence:** [SEARCH-BENCHMARK.md](../benchmarks/SEARCH-BENCHMARK.md)

## Context
Section 5 requires, at a minimum: vocalized and unvocalized search, hamza differences, alif maqsura and ya, ta marbuta and ha "per the approved search algorithm", the definite article, search in hadith texts, books and chapters, by narrator, by topic, in related scholarly information, suggestions while typing, match highlighting, ranking "by match accuracy and available scholarly criteria", and direct navigation to content. Response time target: under one second on the agreed data volume.

Two of these cannot be settled by engineering alone: the ta marbuta/ha rule is defined by an algorithm the First Party must approve, and the scholarly ranking criteria are theirs to define.

## Options considered
Measured in Docker on one Apple M1 laptop, each engine capped at 2 CPUs and 2 GiB, on 46,769 vocalized hadith records from a public corpus (Jaguar16/open-hadith-data v1.1.0). Normalization was tested with 2,000 phrase queries per variant. Latency was tested on the real corpus and on synthetic 10x and 50x copies. Full tables and limits are in the benchmark report.

| | OpenSearch 3.9 | Meilisearch 1.55 | PostgreSQL 16 full-text |
|---|---|---|---|
| Named in the annex | Yes | Yes | No: needs First Party approval |
| Extra service to run | Yes (about 1.6-1.9 GiB of memory, 1 GiB heap, in our setup) | Yes (about 0.6-2.0 GiB) | No |
| Arabic normalization without custom work | Recall 0.00 on every variant (standard analyzer) | 0.86-0.95, but 0.13 for the definite article | Recall 0.00 (simple config) |
| Arabic normalization with our custom chain ("merged" rule) | 0.94-0.98 on every variant | 0.86-0.90; no gain over defaults except the article (0.13 to 0.86) | 0.94-0.98 on every variant |
| Control over the ta marbuta/ha rule | Full: the analyzer is ours. "Strict" (no folding) scored 0.00 on the ta marbuta variant, "merged" 0.97 | Limited: even our "strict" copy matched ta marbuta/ha (0.89), which suggests the built-in tokenizer folds it and we could not turn that off | Full (SQL functions) |
| Highlight in the original vocalized text | Works in all configurations (span precision about 1.0) | 57% highlighted when queries are normalized by our application; 96% with default config | Not solved: 15% highlighted with `ts_headline` |
| Suggestions while typing | Adjacent-prefix precision 0.99, but 27% of queries returned nothing | Last word only, adjacency not enforced (precision 0.66) | Partial (precision 0.55) |
| Field boosts / boost by hadith grade | Numeric weights; grade boost raised the sahih share of the top 10 from 0.29 to 0.80 | Attribute order only (our test showed no effect: 0 of 21 queries, possibly a flaw in our test, not confirmed); grade boost via a derived field (0.33 to 0.79) | Numeric weights; grade boost 0.23 to 0.78 |
| Narrator search in isnad (document counts equal to a reference count) | 13 of 15 names | 1 of 15 (final-word prefix matching inflates counts) | 15 of 15 |
| Latency, real corpus (p99, concurrency 1 / 10 / 50) | 4.6 / 65 / 117 ms | 6 / 39 / 68 ms | 56 / 725 / 5,125 ms (reduced run, 3,000 requests) |
| Latency, 10x synthetic corpus (p99, concurrency 10 / 50) | 75 / 176 ms | 2.5 s / 14.6 s (time-capped runs) | 2.5 s / 19.3 s (reduced run) |
| Latency, 50x synthetic corpus (p99, concurrency 50) | 411 ms | Index build did not finish | Not run |
| Index size, real corpus | 95 MB | 553 MB | 537 MB |
| Bulk update of 1,000 documents | about 1.1 s | about 42 s | about 1.3 s |
| One document searchable after update (median) | about 1.0 s (refresh interval) | about 0.1 s (2 of the test documents were not seen) | about 2 ms |
| Index updates on publish (ADR-012 jobs) | Reindex job writes to the engine | Same | In the same database, so no separate job |

At real corpus size all three engines meet the one-second target at concurrency 1 and 10. At concurrency 50, PostgreSQL did not (p95 1.7 s, p99 5.1 s) in its untuned configuration.

## Decision
We recommend **OpenSearch with a custom Arabic analyzer chain**, pending the scholar approvals below. We are taking this to the First Party as our selection, and it is one of the two engines Annex 17 names.

Why OpenSearch:
- **We control the normalization algorithm.** Section 5 asks for ta marbuta/ha handling "per the approved algorithm". In OpenSearch the algorithm is a short analyzer definition, and switching between the strict and merged rules is a configuration change followed by a reindex. In Meilisearch the built-in tokenizer already folds ta marbuta/ha, and our test could not undo it.
- **Highlighting lands on the original vocalized text** in every configuration we tested. Meilisearch needed custom work and highlighted only 57% of normalized queries. PostgreSQL's built-in highlighting did not work with normalized queries.
- **Latency headroom.** p99 stayed at or below 0.41 s everywhere we measured, including a synthetic 50x corpus at 50 concurrent requests. The real corpus is far smaller than that.
- **Cheap to maintain our rules:** one index definition (about 180 lines of settings), no application-side normalizer, and no duplicated stored fields.

What it costs: the largest memory footprint of the three (about 1.6-1.9 GiB at a 1 GiB heap in our setup), a 1.3 GB image, a single updated document taking about one second to become searchable, and suggestion queries returning nothing for 27% of test inputs, which needs tuning.

Why not the others:
- **Meilisearch** met the target at real size and is lighter to run. We do not recommend it because we could not control the ta marbuta/ha rule, highlighting needed custom work, bulk updates were slow, and it was far slower at 10x with 10-50 concurrent requests. Those latency numbers come from time-capped runs with typo tolerance off and a reduced schema, so they show the direction, not a precise limit. If the First Party prefers it, it remains a workable option at the current corpus size.
- **PostgreSQL full-text search** has the least operational weight, and its normalization works with custom SQL functions. It is not named in the annex, highlighting is unsolved, and the real-size result at concurrency 50 missed the target. Our run was reduced (1 index run, 3,000 requests per cell), so we do not rule it out for a later, smaller use such as admin-side search.

## Validation required
What we validated ourselves (see report): recall for diacritics, hamza, alif maqsura and ya, ta marbuta and ha, definite article, combinations and reordered marks; presence of suggestions, highlighting, filters and navigation; latency, memory and index time at several corpus sizes.

What needs the First Party's scholars (or scholars they nominate):
- Approval of the ta marbuta/ha handling and the "al-" rule (Section 5, items 4 and 5). Strict and merged differ only on this: strict scores 0.00 on the ta marbuta variant and 0.33 on the combined variant, merged 0.94-0.98. We have not chosen between them.
- Definition of the "scholarly criteria" for ranking (item 13): which signals count (for example hadith grade, source, book, exact match vs partial), and in what order.
- A judgment set of 20-30 real queries with the results scholars expect at the top. We prepared a blind review pack of 30 queries comparing the three engines, with the answer key held separately. It uses a public corpus, not the client's data.
- Review of the engine's ranking against that judgment set.

Until the second list is done, the accurate statement is that the chosen engine meets the technical requirements. It is not a claim that the ranking is scholarly-correct.

Not validated on real data: narrator search (the corpus has English transliterated narrator names only), topic search and related scholarly information (the corpus has no topics or explanations).

## Consequences
- The search engine choice is recorded with evidence, and the open items are visible to the client from the start instead of appearing at Phase 2 acceptance.
- The scholars' review is a dependency for Phase 2. It should be scheduled early, because ranking changes are cheap before launch and expensive after.
- A ta marbuta/ha or "al-" rule change after launch means a full reindex. Reindex time on the real corpus was about 17 seconds in our test, so this is cheap while the corpus is small.
- Ask the First Party for a real sample of the corpus, a query list, and the agreed data volume. The decision should be re-checked against them.
- Trade-off we accept: until scholars are involved, ranking is provisional.

## Limits of the evidence
- The run was stopped after about 3.5 hours. Pass 2 (reversed order) was not run, so ordering and cache effects are not measured.
- Meilisearch's 50x index did not finish, and its 10x cells at concurrency 10 and 50 were time-capped.
- PostgreSQL was re-run in reduced form (1 index run, 3,000 requests per cell, 10x only). Its cells are not comparable to the 5 x 5,000 cells for the other two. Meilisearch's idle memory and settings dump were lost.
- 10x and 50x corpora are synthetic duplicates in a smaller schema, used for latency only.
- One laptop, with the load generator sharing the same virtual machine. Meilisearch ran with typo tolerance off and no engine was tuned beyond the settings listed in the report.
- The corpus is a public dataset extracted from sunnah.com whose redistribution rights are unverified. It was used locally only and is not in this repository.
- Ranking quality was not assessed.
