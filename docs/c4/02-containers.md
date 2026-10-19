# C4 level 2: Containers

Applications and data stores that make up Noor (drawn as a C4-style flowchart for readable layout; solid arrows are calls, dotted arrows are asynchronous or edge paths). Mobile and public web are covered by ADR-016 and ADR-017.

```mermaid
flowchart LR
  reader(["Reader / listener"])
  staff(["Editor, reviewer, admin"])
  ext["Push services and email<br/>APNs, FCM, email service"]
  cdn["CDN and WAF"]

  subgraph noor["Noor platform"]
    direction LR
    subgraph clients["Client applications"]
      mobile["Mobile apps<br/>React Native (ADR-016)"]
      web["Public web<br/>Next.js (ADR-017)"]
      admin["Admin dashboard<br/>React, TypeScript (ADR-011)"]
    end
    api["API<br/>Node.js, Express, TypeScript<br/>modular monolith<br/>(ADR-001, 009, 010)"]
    workers["Workers<br/>Node.js, pg-boss (ADR-012)"]
    subgraph data["Data stores"]
      pg[("PostgreSQL 16<br/>ADR-002, 003")]
      search[("OpenSearch<br/>ADR-013")]
      redis[("Redis<br/>cache and rate limiting")]
      files[("Object storage<br/>S3-compatible")]
    end
  end

  reader --> mobile
  reader --> web
  staff --> admin
  mobile -->|"HTTPS / JSON"| api
  web -->|"HTTPS / JSON"| api
  admin -->|"HTTPS / JSON"| api
  mobile -.->|"audio streaming"| cdn
  cdn -.-> files
  api -->|"Prisma"| pg
  api --> search
  api --> redis
  api -->|"signed URLs"| files
  workers -->|"jobs, results"| pg
  workers -->|"index"| search
  workers -->|"audio"| files
  workers --> ext
  api -.->|"enqueue in the same transaction"| workers
```

Notes:
- The API enqueues jobs in the same PostgreSQL transaction as the content change (ADR-012). Workers run as separate containers on a separate host (ADR-015).
- Radio Noor: the scheduled option is served by the API; an optional live stream adds a streaming server and the CDN ([ADR-014](../adr/ADR-014-radio-noor.md)).
- Search is rebuilt from PostgreSQL if lost (ADR-004, ADR-013).
