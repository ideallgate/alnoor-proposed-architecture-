# Noor Arabic search bake-off — SEARCH-BENCHMARK.md

> **READ FIRST — this run is incomplete.** The brief asked for two full passes. The run was stopped on request after ~3.5 h to meet a deadline. What exists:
> - **Pass 1:** OpenSearch complete (5 index runs, T1–T4, 10x and 50x). Meilisearch complete through 10x; its **50x was not finished** (index build exceeded ~100 min and was killed). **PostgreSQL was re-run in reduced form** (1 index run, T3 with 1 run × 3,000 requests, 60 s cap per run, 10x only, 1 update run) because the full PG run was cut. Reduced cells are not comparable to the OpenSearch/Meilisearch 5×5,000 cells.
> - **Pass 2 (reversed order) was NOT run.** All "P2" columns are empty. No reversed-order sanity check exists, so ordering/cache effects are unmeasured.
> - T3 50x exists for OpenSearch only. Meilisearch 10x cells at concurrency 10/50 and PG 10x cells were time-capped (request counts shown in the table).
> - Postgres cold-start/idle-memory and Meilisearch idle memory/settings dump were partly lost to a cleanup mistake; shown as "–".
> - Hardware note: T1 recall is deterministic, so it was run once per engine rather than 5 times.

## Environment
- Host: Mac (Darwin 25.6), Docker 29.8.1, Docker VM 8 CPUs / 7.75 GiB RAM, 62.8 GB VM disk. Host used only for bash orchestration (docker, curl, bc); a few result files were inspected with host python/zip.
- Caps: each engine 2 CPUs / 2 GiB (OpenSearch heap 1 GiB); runner 2 CPUs / 2 GiB. One engine up at a time.
- Images (digests in T5): OpenSearch 3.9.0 (security plugin off, single node), Meilisearch v1.55.0, PostgreSQL 16.15, runner node:24.22.0-slim. Client libs: @opensearch-project/opensearch 3.9.0, meilisearch 0.62.0, pg 8.23.1, TypeScript 7.0.2 (compiled at image build).
- Server tuning applied only to fit the caps: Meili `MAX_INDEXING_MEMORY=1GiB`; PG `shared_buffers=512MB, effective_cache_size=1GB, maintenance_work_mem=256MB, work_mem=16MB, max_wal_size=2GB`.

## Dataset and rights caveat
Corpus: `data/open-corpus/hadith.jsonl` (46,769 narrations, 14 collections; Jaguar16/open-hadith-data v1.1.0; `data/client-sample/` does not exist). **Rights: extracted from sunnah.com; redistribution rights are unverified. Used locally only; nothing uploaded; corpus-derived files are excluded from the zip.** Known gaps: `narrator` is English transliteration (unusable); `topics` empty; no explanations; `grade_class` non-null for 43.55%; chapter is sometimes a fallback to the book title. Stored data not normalized (37% differ from matn only in mark order).
Scaled copies (10x/50x) are **synthetic** (duplicates with one word dropped) and used for latency/size only, never relevance. To fit disk/time they use a **"lite" schema** (matn search + book/grade filters only); `lite-x1` is the real corpus in the same schema for comparison.

## Settings per engine (full dumps: `results-pass1/settings-*.json`, code in `src/`)
- **OpenSearch** (`src/opensearch.ts`): 1 shard, 0 replicas. Each of text_ar/matn_ar/isnad_ar/book/chapter is `text` with 4 analyzers as subfields: `none`=standard; `rec`=built-in `arabic` analyzer (normalization + stemmer + stopwords); `strict`/`merged` = custom: char filters (strip U+064B–065F, 0670, tatweel, Quranic marks; fold أإآٱ→ا, ى→ي, ؤ→و, ئ→ي; merged adds ة→ه), standard tokenizer, token filter stripping leading «ال». Filters/boosts via keyword fields `book_kw`, `chapter_kw`, `grade_class`, `grade_rank`. Bulk load with refresh disabled, then refresh. Queries: `match_phrase`, `match` (AND), `match_phrase_prefix`; unified highlighter on the subfield.
- **Meilisearch** (`src/meili.ts`): default charabia tokenization (this is also its "recommended"; `none` and `rec` are identical, so `rec` columns repeat `none`). Typo tolerance **disabled** (to isolate normalization; typo tolerance is not evaluated). `matchingStrategy: all`. Primary key must be sanitized (`doc_key`; ids contain `:`). Custom work: app-side normalized copies of every field (`*_strict`, `*_merged`) with the same rules as above, queries normalized in application code. Meilisearch always prefix-matches the final query word (cannot be disabled per query), which widens "terms" matches.
- **PostgreSQL** (`src/pg.ts`): generated `tsvector` columns per field × config: `none`=`simple`, `rec`=built-in `arabic` snowball config, `strict`/`merged` = `simple` over SQL functions `ar_norm_s/ar_norm_m` (same rules), GIN indexes created after load. Queries: `phraseto_tsquery`, `plainto_tsquery`, `to_tsquery` with `:*`; `ts_rank`. Baseline only, not an annex engine.
- Method gaps: no engine is tuned beyond the above; warm-up 300 requests (OpenSearch/first Meili cells) or 20 s max (later cells); a request error is counted, never retried.

## T1 tables (recall@10 / MRR; n = applicable queries)

Pass 1 values; `agree` lines state whether pass 2 is identical (T1 is deterministic).

### matn_ar, phrase query

| variant | n | OP:none | OP:rec | OP:strict | OP:merged | ME:none | ME:rec | ME:strict | ME:merged | PO:none | PO:rec | PO:strict | PO:merged |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| o original (as stored) | 2000 | 0.94 / 0.96 | 0.97 / 0.89 | 0.97 / 0.89 | 0.97 / 0.89 | 0.93 / 0.87 | 0.93 / 0.87 | 0.89 / 0.82 | 0.87 / 0.80 | 0.94 / 0.95 | 0.96 / 0.84 | 0.96 / 0.87 | 0.96 / 0.86 |
| a no diacritics | 1940 | 0.00 / 0.00 | 0.90 / 0.79 | 0.97 / 0.90 | 0.97 / 0.90 | 0.86 / 0.81 | 0.86 / 0.81 | 0.89 / 0.83 | 0.87 / 0.81 | 0.00 / 0.00 | 0.95 / 0.84 | 0.97 / 0.87 | 0.97 / 0.87 |
| b partial diacritics | 1934 | 0.00 / 0.00 | 0.96 / 0.88 | 0.97 / 0.90 | 0.97 / 0.90 | 0.88 / 0.84 | 0.88 / 0.84 | 0.89 / 0.83 | 0.87 / 0.81 | 0.00 / 0.00 | 0.95 / 0.85 | 0.97 / 0.88 | 0.97 / 0.88 |
| c1 hamza dropped | 1162 | 0.00 / 0.00 | 0.86 / 0.79 | 0.98 / 0.90 | 0.98 / 0.90 | 0.94 / 0.88 | 0.94 / 0.88 | 0.89 / 0.82 | 0.86 / 0.80 | 0.00 / 0.00 | 0.80 / 0.70 | 0.97 / 0.87 | 0.97 / 0.87 |
| c2 hamza forms swapped | 1553 | 0.00 / 0.00 | 0.97 / 0.89 | 0.97 / 0.90 | 0.97 / 0.90 | 0.92 / 0.87 | 0.92 / 0.87 | 0.88 / 0.81 | 0.86 / 0.79 | 0.00 / 0.00 | 0.46 / 0.40 | 0.97 / 0.86 | 0.97 / 0.86 |
| d ى↔ي | 1434 | 0.00 / 0.00 | 0.96 / 0.89 | 0.97 / 0.90 | 0.97 / 0.90 | 0.92 / 0.87 | 0.92 / 0.87 | 0.88 / 0.81 | 0.86 / 0.79 | 0.00 / 0.00 | 0.05 / 0.04 | 0.97 / 0.87 | 0.97 / 0.87 |
| e ة↔ه | 1285 | 0.00 / 0.00 | 0.96 / 0.89 | 0.00 / 0.00 | 0.97 / 0.89 | 0.93 / 0.87 | 0.93 / 0.87 | 0.89 / 0.81 | 0.86 / 0.79 | 0.00 / 0.00 | 0.22 / 0.19 | 0.00 / 0.00 | 0.97 / 0.87 |
| f article add/remove | 1880 | 0.00 / 0.00 | 0.85 / 0.79 | 0.96 / 0.88 | 0.96 / 0.88 | 0.13 / 0.12 | 0.13 / 0.12 | 0.88 / 0.81 | 0.86 / 0.79 | 0.00 / 0.00 | 0.47 / 0.42 | 0.96 / 0.86 | 0.96 / 0.86 |
| g combination (a+c1+d+e+f) | 2000 | 0.00 / 0.00 | 0.77 / 0.70 | 0.34 / 0.31 | 0.95 / 0.88 | 0.16 / 0.15 | 0.16 / 0.15 | 0.88 / 0.81 | 0.86 / 0.80 | 0.00 / 0.00 | 0.06 / 0.06 | 0.33 / 0.30 | 0.94 / 0.85 |
| h marks reordered (shadda first) | 397 | 0.10 / 0.22 | 0.97 / 0.91 | 0.98 / 0.92 | 0.98 / 0.92 | 0.95 / 0.91 | 0.95 / 0.91 | 0.90 / 0.85 | 0.88 / 0.83 | 0.10 / 0.22 | 0.97 / 0.89 | 0.98 / 0.91 | 0.98 / 0.91 |

### matn_ar, terms query

| variant | n | OP:none | OP:rec | OP:strict | OP:merged | ME:none | ME:rec | ME:strict | ME:merged | PO:none | PO:rec | PO:strict | PO:merged |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| o original (as stored) | 2000 | 0.92 / 0.91 | 0.90 / 0.79 | 0.93 / 0.82 | 0.93 / 0.82 | 0.92 / 0.85 | 0.92 / 0.85 | 0.89 / 0.81 | 0.87 / 0.80 | 0.92 / 0.90 | 0.86 / 0.69 | 0.91 / 0.77 | 0.91 / 0.77 |
| a no diacritics | 1940 | 0.00 / 0.00 | 0.84 / 0.69 | 0.93 / 0.83 | 0.93 / 0.83 | 0.92 / 0.84 | 0.92 / 0.84 | 0.89 / 0.82 | 0.87 / 0.80 | 0.00 / 0.00 | 0.86 / 0.69 | 0.91 / 0.78 | 0.91 / 0.78 |
| b partial diacritics | 1934 | 0.00 / 0.00 | 0.89 / 0.77 | 0.93 / 0.83 | 0.93 / 0.83 | 0.92 / 0.84 | 0.92 / 0.84 | 0.89 / 0.82 | 0.87 / 0.80 | 0.00 / 0.00 | 0.86 / 0.69 | 0.92 / 0.78 | 0.92 / 0.78 |
| c1 hamza dropped | 1162 | 0.00 / 0.00 | 0.81 / 0.70 | 0.94 / 0.83 | 0.94 / 0.83 | 0.93 / 0.86 | 0.93 / 0.86 | 0.88 / 0.82 | 0.86 / 0.80 | 0.00 / 0.00 | 0.73 / 0.58 | 0.93 / 0.79 | 0.93 / 0.79 |
| c2 hamza forms swapped | 1553 | 0.00 / 0.00 | 0.90 / 0.79 | 0.93 / 0.82 | 0.93 / 0.82 | 0.92 / 0.85 | 0.92 / 0.85 | 0.88 / 0.81 | 0.86 / 0.79 | 0.00 / 0.00 | 0.42 / 0.34 | 0.92 / 0.77 | 0.92 / 0.77 |
| d ى↔ي | 1434 | 0.00 / 0.00 | 0.90 / 0.79 | 0.94 / 0.83 | 0.94 / 0.83 | 0.92 / 0.85 | 0.92 / 0.85 | 0.88 / 0.81 | 0.85 / 0.79 | 0.00 / 0.00 | 0.05 / 0.04 | 0.93 / 0.78 | 0.93 / 0.78 |
| e ة↔ه | 1285 | 0.00 / 0.00 | 0.90 / 0.79 | 0.00 / 0.00 | 0.94 / 0.82 | 0.93 / 0.86 | 0.93 / 0.86 | 0.89 / 0.81 | 0.86 / 0.79 | 0.00 / 0.00 | 0.21 / 0.17 | 0.00 / 0.00 | 0.92 / 0.77 |
| f article add/remove | 1880 | 0.00 / 0.00 | 0.80 / 0.70 | 0.92 / 0.81 | 0.92 / 0.81 | 0.86 / 0.80 | 0.86 / 0.80 | 0.88 / 0.81 | 0.86 / 0.79 | 0.00 / 0.00 | 0.43 / 0.34 | 0.91 / 0.76 | 0.91 / 0.76 |
| g combination (a+c1+d+e+f) | 2000 | 0.00 / 0.00 | 0.72 / 0.61 | 0.32 / 0.29 | 0.91 / 0.80 | 0.83 / 0.78 | 0.83 / 0.78 | 0.88 / 0.81 | 0.86 / 0.79 | 0.00 / 0.00 | 0.06 / 0.05 | 0.31 / 0.26 | 0.89 / 0.75 |
| h marks reordered (shadda first) | 397 | 0.10 / 0.20 | 0.88 / 0.76 | 0.92 / 0.81 | 0.92 / 0.81 | 0.94 / 0.89 | 0.94 / 0.89 | 0.89 / 0.84 | 0.87 / 0.82 | 0.10 / 0.21 | 0.85 / 0.68 | 0.91 / 0.77 | 0.91 / 0.77 |

### text_ar, phrase query

| variant | n | OP:none | OP:rec | OP:strict | OP:merged | ME:none | ME:rec | ME:strict | ME:merged | PO:none | PO:rec | PO:strict | PO:merged |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| o original (as stored) | 1974 | 0.79 / 0.78 | 0.96 / 0.85 | 0.96 / 0.85 | 0.96 / 0.85 | 0.93 / 0.87 | 0.93 / 0.87 | 0.89 / 0.81 | 0.86 / 0.79 | 0.79 / 0.77 | 0.95 / 0.84 | 0.96 / 0.86 | 0.96 / 0.86 |
| a no diacritics | 1915 | 0.00 / 0.00 | 0.89 / 0.74 | 0.96 / 0.85 | 0.96 / 0.85 | 0.86 / 0.81 | 0.86 / 0.81 | 0.89 / 0.82 | 0.86 / 0.80 | 0.00 / 0.00 | 0.95 / 0.84 | 0.96 / 0.87 | 0.96 / 0.87 |
| b partial diacritics | 1909 | 0.00 / 0.00 | 0.95 / 0.83 | 0.96 / 0.85 | 0.96 / 0.85 | 0.88 / 0.83 | 0.88 / 0.83 | 0.89 / 0.82 | 0.86 / 0.81 | 0.00 / 0.00 | 0.95 / 0.85 | 0.96 / 0.87 | 0.96 / 0.87 |
| c1 hamza dropped | 1150 | 0.00 / 0.00 | 0.86 / 0.76 | 0.97 / 0.86 | 0.97 / 0.86 | 0.94 / 0.88 | 0.94 / 0.88 | 0.89 / 0.81 | 0.86 / 0.79 | 0.00 / 0.00 | 0.80 / 0.70 | 0.97 / 0.87 | 0.97 / 0.87 |
| c2 hamza forms swapped | 1535 | 0.00 / 0.00 | 0.96 / 0.85 | 0.97 / 0.85 | 0.97 / 0.85 | 0.92 / 0.86 | 0.92 / 0.86 | 0.88 / 0.80 | 0.85 / 0.78 | 0.00 / 0.00 | 0.46 / 0.40 | 0.97 / 0.86 | 0.97 / 0.86 |
| d ى↔ي | 1419 | 0.00 / 0.00 | 0.96 / 0.85 | 0.97 / 0.85 | 0.97 / 0.85 | 0.92 / 0.86 | 0.92 / 0.86 | 0.88 / 0.80 | 0.85 / 0.78 | 0.00 / 0.00 | 0.05 / 0.04 | 0.97 / 0.87 | 0.97 / 0.87 |
| e ة↔ه | 1270 | 0.00 / 0.00 | 0.96 / 0.86 | 0.00 / 0.00 | 0.97 / 0.86 | 0.93 / 0.87 | 0.93 / 0.87 | 0.89 / 0.81 | 0.86 / 0.78 | 0.00 / 0.00 | 0.22 / 0.19 | 0.00 / 0.00 | 0.97 / 0.88 |
| f article add/remove | 1854 | 0.00 / 0.00 | 0.85 / 0.76 | 0.96 / 0.85 | 0.96 / 0.85 | 0.13 / 0.12 | 0.13 / 0.12 | 0.88 / 0.81 | 0.86 / 0.79 | 0.00 / 0.00 | 0.47 / 0.41 | 0.96 / 0.86 | 0.96 / 0.86 |
| g combination (a+c1+d+e+f) | 1974 | 0.00 / 0.00 | 0.77 / 0.66 | 0.33 / 0.29 | 0.95 / 0.84 | 0.16 / 0.15 | 0.16 / 0.15 | 0.88 / 0.81 | 0.86 / 0.79 | 0.00 / 0.00 | 0.06 / 0.05 | 0.33 / 0.29 | 0.94 / 0.85 |
| h marks reordered (shadda first) | 394 | 0.97 / 0.96 | 0.96 / 0.87 | 0.97 / 0.87 | 0.97 / 0.87 | 0.94 / 0.89 | 0.94 / 0.89 | 0.90 / 0.85 | 0.88 / 0.83 | 0.97 / 0.96 | 0.96 / 0.88 | 0.98 / 0.91 | 0.98 / 0.91 |

### text_ar, terms query

| variant | n | OP:none | OP:rec | OP:strict | OP:merged | ME:none | ME:rec | ME:strict | ME:merged | PO:none | PO:rec | PO:strict | PO:merged |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| o original (as stored) | 1974 | 0.76 / 0.73 | 0.86 / 0.70 | 0.90 / 0.73 | 0.90 / 0.74 | 0.92 / 0.85 | 0.92 / 0.85 | 0.88 / 0.81 | 0.86 / 0.79 | 0.77 / 0.73 | 0.85 / 0.68 | 0.91 / 0.76 | 0.91 / 0.76 |
| a no diacritics | 1915 | 0.00 / 0.00 | 0.80 / 0.60 | 0.90 / 0.74 | 0.90 / 0.74 | 0.92 / 0.84 | 0.92 / 0.84 | 0.88 / 0.81 | 0.86 / 0.80 | 0.00 / 0.00 | 0.84 / 0.68 | 0.91 / 0.77 | 0.91 / 0.77 |
| b partial diacritics | 1909 | 0.00 / 0.00 | 0.85 / 0.68 | 0.90 / 0.74 | 0.90 / 0.74 | 0.91 / 0.84 | 0.91 / 0.84 | 0.88 / 0.82 | 0.86 / 0.80 | 0.00 / 0.00 | 0.85 / 0.69 | 0.91 / 0.77 | 0.91 / 0.77 |
| c1 hamza dropped | 1150 | 0.00 / 0.00 | 0.78 / 0.63 | 0.92 / 0.75 | 0.92 / 0.75 | 0.93 / 0.86 | 0.93 / 0.86 | 0.88 / 0.81 | 0.86 / 0.79 | 0.00 / 0.00 | 0.72 / 0.57 | 0.92 / 0.78 | 0.92 / 0.78 |
| c2 hamza forms swapped | 1535 | 0.00 / 0.00 | 0.87 / 0.71 | 0.91 / 0.74 | 0.91 / 0.74 | 0.92 / 0.84 | 0.92 / 0.84 | 0.87 / 0.80 | 0.85 / 0.78 | 0.00 / 0.00 | 0.42 / 0.34 | 0.91 / 0.76 | 0.91 / 0.76 |
| d ى↔ي | 1419 | 0.00 / 0.00 | 0.86 / 0.70 | 0.91 / 0.74 | 0.91 / 0.74 | 0.91 / 0.84 | 0.91 / 0.84 | 0.87 / 0.80 | 0.85 / 0.78 | 0.00 / 0.00 | 0.05 / 0.04 | 0.92 / 0.77 | 0.92 / 0.77 |
| e ة↔ه | 1270 | 0.00 / 0.00 | 0.87 / 0.71 | 0.00 / 0.00 | 0.91 / 0.76 | 0.93 / 0.85 | 0.93 / 0.85 | 0.88 / 0.81 | 0.85 / 0.78 | 0.00 / 0.00 | 0.21 / 0.17 | 0.00 / 0.00 | 0.92 / 0.78 |
| f article add/remove | 1854 | 0.00 / 0.00 | 0.77 / 0.62 | 0.89 / 0.73 | 0.89 / 0.73 | 0.94 / 0.85 | 0.94 / 0.85 | 0.88 / 0.80 | 0.85 / 0.78 | 0.00 / 0.00 | 0.43 / 0.34 | 0.90 / 0.75 | 0.90 / 0.75 |
| g combination (a+c1+d+e+f) | 1974 | 0.00 / 0.00 | 0.68 / 0.53 | 0.31 / 0.25 | 0.88 / 0.72 | 0.90 / 0.82 | 0.90 / 0.82 | 0.88 / 0.80 | 0.86 / 0.79 | 0.00 / 0.00 | 0.06 / 0.05 | 0.31 / 0.26 | 0.89 / 0.75 |
| h marks reordered (shadda first) | 394 | 0.92 / 0.84 | 0.82 / 0.67 | 0.86 / 0.72 | 0.86 / 0.72 | 0.92 / 0.87 | 0.92 / 0.87 | 0.89 / 0.84 | 0.87 / 0.82 | 0.94 / 0.87 | 0.82 / 0.67 | 0.89 / 0.76 | 0.89 / 0.76 |

Phrases: 2000 used; skipped for >20 matches: 138; skipped for salutation: 292; text_ar field skipped for >20 matches: 19.


## T3 latency (ms; median of the 5 runs of each cell; both passes)

| engine | corpus | conc | P1 p50/p95/p99 | P1 qps | P1 errors (requests) | P2 p50/p95/p99 | P2 qps | P2 errors (requests) |
|---|---|---|---|---|---|---|---|---|
| opensearch | real-full | 1 | 0.8 / 2.4 / 4.6 | 928 | 0 (25000 req) | – | – | – |
| opensearch | real-full | 10 | 2.1 / 49.5 / 64.9 | 1667 | 0 (25000 req) | – | – | – |
| opensearch | real-full | 50 | 18.1 / 92.6 / 117.0 | 1225 | 0 (25000 req) | – | – | – |
| opensearch | lite-x1 | 1 | 0.6 / 1.5 / 3.5 | 1291 | 0 (25000 req) | – | – | – |
| opensearch | lite-x1 | 10 | 1.6 / 8.8 / 64.8 | 2201 | 0 (25000 req) | – | – | – |
| opensearch | lite-x1 | 50 | 8.2 / 76.8 / 98.0 | 2200 | 0 (25000 req) | – | – | – |
| opensearch | lite-x10 | 1 | 1.0 / 4.0 / 12.8 | 631 | 0 (25000 req) | – | – | – |
| opensearch | lite-x10 | 10 | 3.6 / 61.3 / 75.1 | 964 | 0 (25000 req) | – | – | – |
| opensearch | lite-x10 | 50 | 73.2 / 115.5 / 176.3 | 819 | 0 (25000 req) | – | – | – |
| opensearch | lite-x50 | 1 | 3.1 / 15.8 / 59.7 | 172 | 0 (25000 req) | – | – | – |
| opensearch | lite-x50 | 10 | 20.3 / 101.6 / 202.8 | 238 | 0 (25000 req) | – | – | – |
| opensearch | lite-x50 | 50 | 155.8 / 313.3 / 410.7 | 300 | 0 (25000 req) | – | – | – |
| meilisearch | real-full | 1 | 1.5 / 3.2 / 6.0 | 572 | 0 (25000 req) | – | – | – |
| meilisearch | real-full | 10 | 3.5 / 18.2 / 39.3 | 1911 | 0 (25000 req) | – | – | – |
| meilisearch | real-full | 50 | 15.9 / 62.5 / 68.1 | 1937 | 0 (25000 req) | – | – | – |
| meilisearch | lite-x1 | 1 | 1.1 / 1.8 / 3.2 | 818 | 0 (25000 req) | – | – | – |
| meilisearch | lite-x1 | 10 | 3.0 / 9.2 / 34.8 | 2240 | 0 (25000 req) | – | – | – |
| meilisearch | lite-x1 | 50 | 15.2 / 55.6 / 66.8 | 2188 | 0 (25000 req) | – | – | – |
| meilisearch | lite-x10 | 1 | 20.9 / 62.4 / 97.5 | 39 | 0 (25000 req) | – | – | – |
| meilisearch | lite-x10 | 10 | 800.3 / 1829.4 / 2531.3 | 11 | 0 (14358 req, time-capped) | – | – | – |
| meilisearch | lite-x10 | 50 | 6240.8 / 11321.7 / 14573.5 | 7 | 0 (9714 req, time-capped) | – | – | – |
| meilisearch | lite-x50 | 1 | – | – | – | – | – | – |
| meilisearch | lite-x50 | 10 | – | – | – | – | – | – |
| meilisearch | lite-x50 | 50 | – | – | – | – | – | – |
| postgres | real-full | 1 | 0.6 / 19.4 / 55.6 | 242 | 0 (3000 req) | – | – | – |
| postgres | real-full | 10 | 1.5 / 196.7 / 724.5 | 227 | 0 (3000 req) | – | – | – |
| postgres | real-full | 50 | 5.9 / 1696.9 / 5125.1 | 148 | 0 (3000 req) | – | – | – |
| postgres | lite-x1 | 1 | 0.4 / 7.3 / 14.9 | 674 | 0 (3000 req) | – | – | – |
| postgres | lite-x1 | 10 | 1.8 / 78.7 / 102.4 | 863 | 0 (3000 req) | – | – | – |
| postgres | lite-x1 | 50 | 7.6 / 376.5 / 810.0 | 626 | 0 (3000 req) | – | – | – |
| postgres | lite-x10 | 1 | 2.1 / 81.9 / 139.4 | 71 | 0 (3000 req) | – | – | – |
| postgres | lite-x10 | 10 | 75.4 / 1309.1 / 2533.0 | 42 | 0 (2526 req, time-capped) | – | – | – |
| postgres | lite-x10 | 50 | 286.3 / 8791.7 / 19302.0 | 28 | 2 (1787 req, time-capped) | – | – | – |
| postgres | lite-x50 | 1 | – | – | – | – | – | – |
| postgres | lite-x50 | 10 | – | – | – | – | – | – |
| postgres | lite-x50 | 50 | – | – | – | – | – | – |

## T4 indexing, updates, memory

| engine | P1 index s median (runs) | P1 size MB | P1 after compact MB | P2 index s median (runs) | P2 size MB | P2 after compact MB |
|---|---|---|---|---|---|---|
| opensearch | 16.8 (29,16,17,18,16) | 95 | 95 | – | – | – |
| meilisearch | 95.7 (95,96,106,102,96) | 553 | – | – | – | – |
| postgres | 50.2 (50) | 537 | 556 | – | – | – |

| engine | lite schema | P1 index s | P1 API size MB | P1 volume MB | P2 index s | P2 API size MB | P2 volume MB |
|---|---|---|---|---|---|---|---|
| opensearch | lite-x1 | 5 | 19 | 49 | – | – | – |
| opensearch | lite-x10 | 22 | 178 | 472 | – | – | – |
| opensearch | lite-x50 | 140 | 918 | 925 | – | – | – |
| meilisearch | lite-x1 | 15 | 199 | 398 | – | – | – |
| meilisearch | lite-x10 | 269 | 1298 | 2271 | – | – | – |
| meilisearch | lite-x50 | – | – | – | – | – | – |
| postgres | lite-x1 | 4 | 59 | 1143 | – | – | – |
| postgres | lite-x10 | 37 | 533 | 2123 | – | – | – |
| postgres | lite-x50 | – | – | – | – | – | – |

| engine | P1 single→searchable p50/p95 ms | P1 bulk 1000 ms | P1 not-seen | P2 single p50/p95 ms | P2 bulk 1000 ms | P2 not-seen |
|---|---|---|---|---|---|---|
| opensearch | 1022 / 1057 | 1070 | 0 | – | – | – |
| meilisearch | 101 / 113 | 42270 | 2 | – | – | – |
| postgres | 2 / 6 | 1310 | 0 | – | – | – |

### Container memory (MiB, median / max of docker-stats samples every ~2 s; cap 2048)

| engine | pass | idle (after start) | index (real) | t1+t2 | t3 (all sizes) | updates | scaled index builds |
|---|---|---|---|---|---|---|---|
| opensearch | pass1 | 1562 / 1564 | 1584 / 1598 | 1624 / 1629 | 1868 / 1879 | 1635 / 1637 | 1708 / 1905 |
| meilisearch | pass1 | – | 592 / 683 | 686 / 739 | 1424 / 2035 | 770 / 874 | 1413 / 2028 |
| postgres | pass1 | 122 / 122 | 613 / 746 | 703 / 731 | 764 / 1118 | 653 / 653 | 684 / 748 |

## T5 operability

| engine | image size | image digest | cold start s (P1 / P2) | settings dump lines | settings keys |
|---|---|---|---|---|---|
| opensearch | 1311 MB | opensearchproject/opensearch@sha256:adfa61f85025d06b4aeb562e7e74fde7e31c437039c93c3862c17e9acebd6c7c | 15.0 / – | 180 | 108 |
| meilisearch | 370 MB | getmeili/meilisearch@sha256:ff546679970126f8822e15d1b6a06bfbff1f2ce2e43f810cfb5258012f92de5c | 0.5 / – | – | – |
| postgres | 474 MB | postgres@sha256:ca0bd484cb98bf4b24eb1010e73fb3fcbd6714d240fbc1a10eea5b7dbecb641d | 5.5 / – | 29 | 3 |

## Findings (numbers above only; no ranking-quality conclusions)
Section 5 items, status per engine (evidence = `results-pass1/t2-*.json`):

| Item | OpenSearch | Meilisearch | PostgreSQL (baseline) |
|---|---|---|---|
| Search hadith text / matn | works (source doc in top-10 for 97% / 97% of 150 unvocalized phrase queries) | works (88% / 88%) | works (92% / 93%) |
| Books and chapters | works (book P@10 1.0; chapter 0.95) | works (1.0; 0.95) | works (1.0; 0.90) |
| Suggestions while typing | works: adjacent-prefix precision 0.99 but 27% empty (match_phrase_prefix, max_expansions 50) | works natively but last-word prefix only, adjacency not enforced (precision 0.66, 4.5% empty) | partial: `:*` AND query, precision 0.55 |
| Highlight in original vocalized text_ar | works for all configs (span precision ≈1.0, query-term coverage 1.0; `rec` stemming 0.87) | partial: works with default config (96% highlighted) but only 57% with app-normalized queries (needs custom work) | needs custom work: `ts_headline` only matches un-normalized words (15% highlighted, coverage ≈0.4) |
| Ranking: field boosts | works (numeric weights; top-10 changed for 19/21 queries) | partial: only attribute priority order; no change observed in my test (0/21) — may be a flaw of my test, not validated | works (numeric weights; 20/21 changed) |
| Ranking: boost by grade_class | works (sahih share of top-10 0.29 → 0.80) | partial: `sort` on a derived numeric `grade_rank` (custom field) 0.33 → 0.79 | works (custom ORDER BY expression) 0.23 → 0.78 |
| Navigation to document id | works (60/60 round-trips) | works (needs sanitized key) | works |
| Narrator names in isnad_ar ("partially validated") | works: doc counts equal oracle for 13/15 names; P@10 1.0 | partial: counts equal oracle for only 1/15 (final-word prefix matching inflates) ; P@10 0.99 | works: 15/15 counts equal oracle; P@10 1.0 |
| Topic / related-information search | capability only, not validated: filter, facets, boost on book/chapter/grade_class work | capability only: filter/facets work; chapter facet differed from oracle (false) | capability only: all work |

Normalization (T1, tables above): with no custom normalization OpenSearch (`standard`) and PostgreSQL (`simple`) return nothing for diacritic-stripped, hamza, ya, ta marbuta, article and combined variants (recall 0.00), and 0.10 for mark-reordered queries; Meilisearch defaults already handle diacritics/hamza/ya/ta marbuta/mark order (0.86–0.95) but not the definite article (0.13) or combinations (0.16). With the engine's built-in Arabic chain (`rec`) OpenSearch is 0.77–0.97 across variants; PG `rec` is weak on hamza/ya/ta marbuta (0.05–0.47). With the shared custom chain, **merged** gives 0.94–0.98 on both OpenSearch and PG for every variant, including the combination. **Strict** gives 0.00 on the ta marbuta↔ha variant and 0.33 on the combination (as expected, because it does not fold ة/ه) but otherwise equals merged. The client must decide strict vs merged; no choice is made here. Meilisearch's custom copies stay at 0.86–0.90 for all variants (its tokenizer also normalizes, and final-word prefix matching adds noise), i.e. custom work gave no recall gain there and the article variant improved from 0.13 to 0.86.

Needs custom work (amount): OpenSearch — one index JSON (~180 lines dump), no application code. Meilisearch — an application-side normalizer (`src/norm.ts`, ~20 lines), derived fields doubling stored fields, sanitized key, grade_rank field; index size and 1,000-document bulk update (≈42 s, includes re-fetching documents) suffer. PostgreSQL — DDL with 20 generated tsvector columns and 2 SQL functions (~30 lines), highlighting not solved.

Selected numbers against the "under one second" target: see T3. OpenSearch p99 ≤ 0.41 s in all cells including 50x lite at 50 concurrent. Meilisearch: p99 ≤ 0.07 s at real size, 97 ms at 10x/c=1 but 2.5 s (c=10) and 14.6 s (c=50) at 10x, with request counts capped. PostgreSQL (reduced runs, 3,000 requests): p99 5.1 s at real size c=50 and 19 s at 10x c=50. The 50x cells for Meilisearch and PostgreSQL are missing.

## Limits
Single laptop; the load generator shares the Docker VM CPUs; one corpus; scaled copies are synthetic and in a lite schema; ranking quality is **not assessed** and requires scholar review (see review pack); narrator, topic and related-information search are not validated on real data; pass 2 not run; PG and Meilisearch runs reduced/incomplete as listed at the top; T1 text_ar tables exclude queries whose matn phrase is absent from text_ar (n shown); "terms" queries mean any-order AND (Meilisearch with final-word prefix). Two PG requests errored (10x, c=50). OpenSearch index size after load is before force-merge ("after compact" column is post force-merge / VACUUM FULL). Volume sizes for PG lite cells include earlier data in the same volume and are unreliable. The reviewer pack uses the **strict** configuration of each engine, top 10, highlights where the engine provides them.

## Scholar review pack (local, derived from corpus)
`review-pack/blind-review.local.html` (30 queries, engines A/B/C shuffled per query), `review-pack/rating-form.local.csv`, answer key `review-pack/ANSWER-KEY-do-not-share-with-reviewer.csv`.
