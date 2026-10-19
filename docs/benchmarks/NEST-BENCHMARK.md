# NEST-BENCHMARK — NestJS vs plain Node.js + Express

## Environment
- Host: MacBook M1, 8 GB, macOS 26.6.2, Docker Desktop (engine 29.8.1, VM 8 CPUs / ~8.3 GB). Everything ran in Docker.
- Caps on every compose command: `APP_CPUS=3 APP_MEM=3g PG_CPUS=1 PG_MEM=1g`.
- Runner image `noor-benchmark-kit-n24-l13-nest-bench` id `sha256:7350284f0a8c…` (ubuntu:24.04 base, Node v24.22.0, ab from apache2-utils). Database: `postgres:16` @ `sha256:ca0bd484cb98bf4b24eb1010e73fb3fcbd6714d240fbc1a10eea5b7dbecb641d`. (The ubuntu base digest was not captured.)
- Settings: STACKS=node,nest-express,nest-fastify (reversed in pass 2), CONCURRENCIES=100,1000, 5 runs per cell (median reported), 20,000 requests per run, 2,000 warm-up, RUN_AUDIO=0, soak and wrk cross-check off. Endpoints `/health`, `/radio/now`, `/hadith/4242`.
- Versions (exact pins, `nest/package-lock.json` committed): @nestjs/core 12.1.3, @nestjs/common 12.1.3, @nestjs/platform-express 12.1.3 (brings **express 5.2.1**), @nestjs/platform-fastify 12.1.3, fastify 5.12.5, reflect-metadata 0.2.2, rxjs 7.8.2, typescript 7.0.2, pg 8.13.1; dev: @types/node 26.6.5, @types/pg 8.23.1, @types/express 5.0.6. Baseline `node` stack: express 4.21.2, pg 8.13.1.
  - fastify is pinned to 5.12.5 (not the newest 5.12.7) because that is the exact version platform-fastify depends on; this avoids two fastify copies.
  - TypeScript 7.0.2 rejects `moduleResolution: node`, so that option is omitted from `tsconfig.json`.

## What changed and why
Original files were saved as `<file>.orig`.
- `nest/` (new): `AppModule`, `AppController` (3 routes), `AppService` (SQL and response shaping copied from `node/server.js`), `pool.provider.ts` (pg Pool via DI: host DB_HOST, bench/bench/noor, max 10), and two entry points `main-express.ts` / `main-fastify.ts`. No pipes, guards, interceptors, filters or middleware; Nest logger off; listens on 127.0.0.1:8080; `x-powered-by` disabled on the Express variant like `node`. TypeScript is compiled with `tsc` at image build time and the compiled JS is what runs.
- `benchctl`: `nest-express` / `nest-fastify` cases, usage line, `stop`.
- `env.sh`, `run_all.py`, `docker-compose.yml`, `resource_refresh.py`, `run_soaks.py`: new names added to default STACKS; the process matcher in `run_all.py` (and the two helpers) also recognises `nest/dist/main-*` so app memory is sampled for Nest.
- `docker/Dockerfile`: `npm ci` and `tsc` build for `nest/` (Node 24, same base).
- `report.py`: configuration labels for the new stacks. `check.sh`: reports the nest build. `.dockerignore`: excludes `nest/node_modules`, `nest/dist`.
- `parity.sh` needed no change (it reads STACKS; `node` stays the reference). Endpoints, SQL, request counts and worker counts of existing stacks are unchanged.

## Parity
`check`: READY, seed checksum 2096700. `parity`: **PARITY OK: hadith bodies byte-identical; radio shape and records match** for node, nest-express, nest-fastify. The `/health` and 404 bodies were also identical. Response headers are not identical (e.g. Express sends an ETag, Fastify does not).

## Results
Median req/s over 5 ab runs (min–max in brackets); ratios are Nest ÷ node. Every row: 0 failed, 0 non-2xx (180 runs).

### Pass 1 (node → nest-express → nest-fastify)

| Endpoint | c | node req/s (min–max) | nest-express req/s (min–max) | nest-fastify req/s (min–max) | express/node | fastify/node | p95 ms node / n-express / n-fastify |
|---|---:|---|---|---|---:|---:|---|
| /health | 100 | 35863 (30705–36271) | 30724 (27036–32148) | 52592 (45885–53416) | 0.857 | 1.466 | 3 / 4 / 2 |
| /health | 1000 | 30255 (30026–32516) | 28197 (27067–29949) | 43979 (40933–47499) | 0.932 | 1.454 | 35 / 42 / 28 |
| /radio/now | 100 | 5581 (5379–5643) | 5626 (5306–5750) | 5488 (5281–5661) | 1.008 | 0.983 | 52 / 48 / 54 |
| /radio/now | 1000 | 5555 (5483–5658) | 5732 (5429–5740) | 5558 (5407–5660) | 1.032 | 1.001 | 245 / 222 / 219 |
| /hadith/4242 | 100 | 6498 (5830–6848) | 6668 (6545–6738) | 6671 (6637–6710) | 1.026 | 1.027 | 47 / 43 / 51 |
| /hadith/4242 | 1000 | 6680 (6519–6841) | 6801 (6654–6870) | 6682 (6505–6852) | 1.018 | 1.000 | 197 / 196 / 187 |

### Pass 2 (nest-fastify → nest-express → node)

| Endpoint | c | node req/s (min–max) | nest-express req/s (min–max) | nest-fastify req/s (min–max) | express/node | fastify/node | p95 ms node / n-express / n-fastify |
|---|---:|---|---|---|---:|---:|---|
| /health | 100 | 34616 (31762–35833) | 31389 (24470–32809) | 52138 (45417–53275) | 0.907 | 1.506 | 3 / 4 / 3 |
| /health | 1000 | 30397 (29521–32099) | 29942 (28117–30880) | 43754 (40829–46671) | 0.985 | 1.439 | 40 / 34 / 24 |
| /radio/now | 100 | 5634 (5393–5651) | 5610 (5547–5726) | 5526 (5431–5605) | 0.996 | 0.981 | 51 / 48 / 53 |
| /radio/now | 1000 | 5586 (5473–5633) | 5732 (5646–5801) | 5567 (5443–5594) | 1.026 | 0.997 | 236 / 222 / 234 |
| /hadith/4242 | 100 | 6849 (5913–6946) | 6702 (6612–6848) | 6667 (5095–6707) | 0.978 | 0.973 | 48 / 44 / 51 |
| /hadith/4242 | 1000 | 6855 (6662–6999) | 6827 (6731–6900) | 6319 (6316–6491) | 0.996 | 0.922 | 193 / 180 / 201 |

### Both passes pooled (median of the two pass medians)

| Endpoint | c | node | nest-express | nest-fastify | express/node | fastify/node |
|---|---:|---:|---:|---:|---:|---:|
| /health | 100 | 35240 | 31057 | 52365 | 0.881 | 1.486 |
| /health | 1000 | 30326 | 29069 | 43866 | 0.959 | 1.447 |
| /radio/now | 100 | 5607 | 5618 | 5507 | 1.002 | 0.982 |
| /radio/now | 1000 | 5571 | 5732 | 5563 | 1.029 | 0.999 |
| /hadith/4242 | 100 | 6674 | 6685 | 6669 | 1.002 | 0.999 |
| /hadith/4242 | 1000 | 6768 | 6814 | 6500 | 1.007 | 0.961 |

### Memory (app process RSS, MB, sampled once per second during ab load)

| Pass | Stack | Idle | Avg under load | Peak |
|---|---|---:|---:|---:|
| 1 | node | 66.4 | 210.0 | 248.0 |
| 1 | nest-express | 96.6 | 228.8 | 265.9 |
| 1 | nest-fastify | 105.5 | 227.7 | 266.7 |
| 2 | node | 66.0 | 203.5 | 247.9 |
| 2 | nest-express | 96.9 | 227.1 | 250.9 |
| 2 | nest-fastify | 105.4 | 224.7 | 268.9 |

Error check: 180 measured runs, total failed = 0, total non-2xx = 0.

## Reading the numbers (no conclusions beyond them)
- `/radio/now` and `/hadith/4242` (database-bound, ~5.5k and ~6.7k req/s): all three stacks are within about ±3% of each other in most cells, and the per-cell run-to-run spread is of similar size. The one larger gap is nest-fastify on `/hadith` at c=1000 in pass 2 (0.922 of node), which did not appear in pass 1 (1.000). We treat these as within noise.
- `/health` (no database): nest-fastify was about 1.44–1.51× node in both passes and both concurrencies, well outside the run spread. nest-express was 0.86–0.93× node in pass 1 and 0.91–0.98× in pass 2; the spread is large (min–max ranges overlap node's at c=1000). Part of this may come from Express 5 (Nest) vs Express 4 (node stack) and from Fastify's different default header/JSON handling; this test did not separate those causes.
- Memory: Nest idles higher (≈97–105 MB vs ≈66 MB). Under load the averages were ≈227–229 MB vs ≈204–210 MB and peaks ≈251–269 MB vs ≈248 MB. PostgreSQL memory is not shown because it runs in a separate container the kit's sampler does not see.
- Order effect: the two passes broadly agree; differences between passes are of the same size as run spread, so no clear warm-up/thermal bias is visible.

## Limits
Single M1 laptop; the load generator (ab) shares CPU with the app inside the same capped container; ab is closed-loop; the Docker VM adds its own overhead; each cell is 5 runs. Numbers compare these stacks with each other and are not production figures. Express major versions differ between `node` (4.21.2) and `nest-express` (5.2.1).

## Contents
`results-pass1/`, `results-pass2/` (each with results.csv, resource_samples.csv, memory_idle.csv, summary.md, charts, raw ab output), `results-pass*.log`, `run_passes.sh`, `make_tables.py`, the kit folder and its zip.
