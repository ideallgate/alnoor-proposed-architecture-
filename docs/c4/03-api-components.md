# C4 level 3: API components (modules)

The API is a modular monolith (ADR-010). Each module owns its tables and is used by others only through its public interface. Lint rules fail CI on forbidden imports. Module names are the "likely modules" from ADR-010 and may change as the design is detailed.

```mermaid
flowchart TB
  clients(["Apps and dashboard<br/>mobile, web, admin"])
  pg[("PostgreSQL")]
  search[("OpenSearch")]
  files[("Object storage")]
  workers["Workers (pg-boss)"]

  subgraph api["API: modular monolith (ADR-010)"]
    direction TB
    http["HTTP layer<br/>Express, Zod, OpenAPI, rate limiting"]
    subgraph core["Core modules"]
      identity["Identity and permissions<br/>CASL (ADR-007), 2FA, audit log"]
      content["Content and versions<br/>ADR-004, 005, 006"]
      approval["Approval cycle<br/>draft, review, publish"]
    end
    subgraph feat["Feature modules"]
      library["Library API<br/>read models for the apps"]
      searchm["Search<br/>queries, suggestions"]
      audio["Audio<br/>uploads, sync points, signed URLs"]
      plans["Plans and progress"]
      radio["Radio (ADR-014)"]
      notif["Notifications"]
      reports["Analytics and reports"]
    end
    bus["Event bus and job publisher<br/>in-process events, pg-boss enqueue"]
  end

  clients -->|"HTTPS / JSON"| http
  http --> identity
  http --> content
  http --> library
  http --> searchm
  http --> audio
  http --> radio
  content --> approval
  library --> content
  library --> plans
  approval -->|"published event"| bus
  bus --> searchm
  bus --> notif
  bus -->|"enqueue"| workers
  content --> pg
  searchm --> search
  audio --> files
```

Rules shown here:
- Content and approval share transactions on purpose and are not split ([ADR-010](../adr/ADR-010-modular-monolith.md)).
- Extraction order if needed: audio, search indexing, radio.
- Not every dependency is drawn. The lint rules, not this diagram, are the source of truth.
