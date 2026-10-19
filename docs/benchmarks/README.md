# Benchmarks

Each report states its setup, results and limits. All runs were done in Docker (or noted otherwise) on one Apple M1 laptop. They compare options with each other and are not production figures. Kits to re-run them are in `benchmarks/kits/`.

| Report | Question | Used by | Kit |
|---|---|---|---|
| [BACKEND-NODE-VS-LARAVEL.md](BACKEND-NODE-VS-LARAVEL.md) | Node.js + Express vs Laravel with Octane | [ADR-001](../adr/ADR-001-backend-framework.md) | `backend-node22-laravel12-kit.zip`, `backend-node24-laravel13-kit.zip` |
| [NEST-BENCHMARK.md](NEST-BENCHMARK.md) | NestJS (Express and Fastify) vs plain Express | [ADR-009](../adr/ADR-009-express-vs-nestjs.md) | `backend-nestjs-vs-express-kit.zip` |
| [QUEUE-BENCHMARK.md](QUEUE-BENCHMARK.md) | BullMQ vs pg-boss vs graphile-worker | [ADR-012](../adr/ADR-012-background-jobs.md) | `queue-kit.zip` |
| [QUEUE-BENCHMARK-S6.md](QUEUE-BENCHMARK-S6.md) | BullMQ with a transactional outbox | [ADR-012](../adr/ADR-012-background-jobs.md) | `queue-kit.zip` |
| [SEARCH-BENCHMARK.md](SEARCH-BENCHMARK.md) | OpenSearch vs Meilisearch vs PostgreSQL for Arabic search (incomplete run) | [ADR-013](../adr/ADR-013-arabic-search.md) | `search-kit.zip` |

The search kit does not include the corpus. It is a public dataset with unverified redistribution rights and was used locally only.
