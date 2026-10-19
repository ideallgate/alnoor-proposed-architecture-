# C4 level 2: Containers

Applications, data stores and supporting services that make up Noor (drawn as a C4-style flowchart for readable layout; solid arrows are calls, dotted arrows are asynchronous or streaming paths). Names match the Structurizr model. Mobile and public web are covered by ADR-016 and ADR-017.

```mermaid
flowchart LR
  learner(["Beneficiary"])
  editor(["Content team and administrators"])
  scholar(["Scholars and approvers"])
  radioListeners(["Third-party radio listeners<br/>(optional, Radio Option B)"])
  push["Apple and Google push services"]
  mail["Email service (to be chosen)"]

  subgraph noor["Noor platform"]
    direction LR
    subgraph clients["Client applications"]
      mobile["Mobile apps<br/>React Native (ADR-016)"]
      web["Public web app<br/>Next.js (ADR-017)"]
      admin["Admin dashboard<br/>React, TypeScript (ADR-011)"]
    end
    edge{{"Edge (WAF and reverse proxy)<br/>BunkerWeb, Riyadh (ADR-025)"}}
    mediaCdn["Media CDN (vendor to be selected)<br/>managed, global (ADR-025, 018)"]
    api["API<br/>Node.js, Express, TypeScript<br/>modular monolith<br/>(ADR-001, 009, 010)"]
    workers["Background workers<br/>Node.js, pg-boss (ADR-012)"]
    playout["Radio playout (optional)<br/>Liquidsoap, Icecast (ADR-014)"]
    subgraph data["Data stores"]
      db[("Database<br/>PostgreSQL 16<br/>ADR-002, 003")]
      searchengine[("Search engine<br/>OpenSearch<br/>ADR-013")]
      cache[("Cache<br/>Redis<br/>cache and rate limiting")]
      storage[("Audio storage<br/>S3-compatible<br/>ADR-018")]
    end
    subgraph ops["Monitoring (separate host)"]
      monitoring["Infrastructure monitoring<br/>Grafana, Uptime Kuma"]
      errors["Error monitoring<br/>GlitchTip, Sentry is the alternative"]
    end
  end

  learner --> mobile
  learner --> web
  editor --> admin
  scholar --> admin
  mobile -->|"HTTPS, JSON"| edge
  web -->|"HTTPS, JSON"| edge
  admin -->|"HTTPS, JSON"| edge
  edge -->|"filtered traffic"| api
  mobile -.->|"audio, byte ranges"| mediaCdn
  web -.->|"audio, byte ranges"| mediaCdn
  admin -.->|"audio preview"| mediaCdn
  radioListeners -.->|"live stream"| mediaCdn
  mediaCdn -.->|"cache miss, private origin"| storage
  mediaCdn -.->|"pulls live stream"| playout
  playout -->|"reads schedule"| api
  playout -->|"reads published audio"| storage
  api -->|"SQL (Prisma)"| db
  api -->|"queries"| searchengine
  api -->|"caches, rate limits"| cache
  api -->|"signed URLs"| storage
  workers -->|"jobs, results"| db
  workers -->|"indexes"| searchengine
  workers -->|"reads and writes audio"| storage
  workers --> push
  workers --> mail
  api -.->|"enqueue in the same transaction"| workers
  mobile -.->|"crash and error reports"| errors
  web -.->|"error reports"| errors
  admin -.->|"error reports"| errors
  api -.->|"errors"| errors
  workers -.->|"errors"| errors
  monitoring -.->|"metrics, uptime checks"| api
  monitoring -.->|"metrics"| workers
  monitoring -.->|"metrics"| db
  monitoring -.->|"metrics"| searchengine
```

Notes:
- The API enqueues jobs in the same PostgreSQL transaction as the content change (ADR-012). Workers run as separate containers on a separate host (ADR-015).
- Web, API and login traffic goes through the self-hosted edge in Riyadh. Only audio and static media go through the managed CDN, so no third party terminates TLS for personal traffic (ADR-025).
- Radio Noor: the scheduled option is served by the API; an optional live stream adds a playout service reached through the CDN ([ADR-014](../adr/ADR-014-radio-noor.md)).
- Search is rebuilt from PostgreSQL if lost (ADR-004, ADR-013).
- Push and email are sent only by the workers in this view. The Notifications module in the API enqueues the jobs (ADR-022).
