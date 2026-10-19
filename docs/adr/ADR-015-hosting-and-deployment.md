# ADR-015: Hosting and deployment: Ubuntu hosts, Docker Compose first, Kubernetes when needed

- **Status:** Accepted by the Executor for the deployment model. Provider, country and region are pending the First Party (Annex 19: "determined in coordination with the First Party and according to approved regulatory requirements").
- **Annex reference:** 17 (Docker, CI/CD, separate environments), 18 (capacity, 99.5% availability), 19 (hosting and operations), 20 (security, PDPL), 21 (backup and restore)
- **Type:** Open (our technical selection; the provider is the First Party's decision)

## Context
Section 19 asks for application servers, a database, separate audio storage, a CDN, progressive audio streaming, a load balancer where needed, a WAF or equivalent, TLS, separate development, testing and production environments, isolation of audio processing and heavy tasks, the ability to add compute and storage without rebuilding, monitoring of resources, failures and costs, and backups separate from production.

Capacity targets (Section 18): 1,500 concurrent sessions at peak, 1,500+ hours of audio, 2 TB of initial storage, API p95 under 500 ms, availability 99.5% monthly (about 3.6 hours of unplanned downtime in a 30-day month, excluding scheduled maintenance).

Search runs on OpenSearch (ADR-013); background jobs on pg-boss (ADR-012); the application is a modular monolith with separate worker processes (ADR-010).

## Options considered
| | A. Ubuntu hosts + Docker Compose | B. Managed Kubernetes from day one | C. Platform-as-a-service / serverless |
|---|---|---|---|
| Fits the annex (Docker, isolation, scaling without rebuild) | Yes. Isolation by moving workers to a separate host. Scaling by larger hosts or more hosts | Yes | Partly: heavy audio tasks and OpenSearch fit poorly |
| Provider independence | High: any provider that offers Ubuntu VMs | Medium: managed cluster features differ by provider | Low |
| Operational weight for a small team | Low | High (cluster upgrades, networking, ingress, secrets) | Low, with higher cost and lock-in |
| Cost at Noor's expected scale | Lowest | Higher (control plane, node minimums) | Highest |
| Automatic failover and rolling updates | Limited: needs a second host and a load balancer; short restarts on deploy | Built in | Built in |
| Handover to another supplier | Simple: Compose files and runbooks | Requires Kubernetes skills | Provider-specific |

## Decision
**Ubuntu LTS hosts running Docker, with Docker Compose for orchestration at launch. Move to Kubernetes when specific triggers are met (below).** All components ship as container images built in CI, so the move changes the orchestrator and not the application.

Layout at launch, per environment (development, testing and production are separate):
- **Application host(s):** reverse proxy with TLS, the API, the web app and the admin dashboard.
- **Worker host:** audio processing (FFmpeg), alignment and other heavy jobs, on a different host from the API so they cannot starve it (Annex 19.10).
- **Data:** PostgreSQL on its own host or managed service, with the pg-boss schema in it (ADR-012); OpenSearch on its own host (ADR-013); Redis for cache and rate limiting only.
- **Audio:** S3-compatible object storage with the origin private. Delivery through a CDN with signed or expiring URLs and byte-range support for progressive playback.
- **Edge:** CDN and WAF in front of the public endpoints, a load balancer when a second application host is added.
- **Monitoring:** error monitoring (Sentry or equivalent), Grafana and Uptime Kuma for infrastructure and uptime, alerts on failures and on cost.

Provider-neutral rules: the application uses only standard PostgreSQL, S3-compatible storage and containers, with no provider-specific service in application code. That keeps Hetzner and the major clouds (AWS, Azure and others the First Party approves) interchangeable. The choice is therefore the First Party's, and we will deploy to whichever is approved. Capabilities Section 19 requires (CDN, WAF, load balancer, object storage, managed backups) differ between providers; we will list how each is provided on the approved provider before build.

### Backups and restore (Annex 21)
- Daily PostgreSQL backup with continuous WAL archiving, so restore to a point in time is possible. Periodic copies of audio and other content.
- Backups stored in a different account or provider and region from production, so one failure cannot remove both.
- Retention per the First Party's approved policy.
- A written restore procedure, and a restore test at least every three months.
- Backup jobs run as systemd timers on the hosts, not in the application queue (ADR-012).

### When we move to Kubernetes
We move when one or more of these hold, measured in production:
- A single application host cannot meet the p95 and availability targets, and adding hosts behind a load balancer becomes hard to manage by hand.
- We need several independently scaled services (for example after extracting a module under ADR-010) and rolling deploys with no downtime.
- The First Party or their provider standardizes on Kubernetes.
Until then Kubernetes adds operating cost without a requirement behind it.

## Consequences
- Benefits: lowest cost and complexity, no lock-in to a provider, simple handover (Compose files, runbooks, CI pipelines).
- **Availability risk we accept and state openly:** with one application host, a host failure or a deploy restart is an outage. 99.5% monthly is achievable with a tested restore and short deploys, but it is not automatic failover. If the First Party wants higher availability, the first step is a second application host behind a load balancer, which Compose supports, and the next is Kubernetes. The availability target will be proven in the performance tests Annex 18 requires.
- Capacity sizing is not yet done. The benchmarks so far were run on one laptop, so production-like load tests are needed before choosing host sizes (SAD section 10).
- **Data location:** Annex 20 requires compliance with the Personal Data Protection Law (PDPL) as applicable to the data. The country and region of hosting, and whether any user data may leave the country, must be confirmed by the First Party. Some providers have no region in the First Party's country. This is an open question for the client, and it may constrain the provider choice.
- Operations: we apply operating-system updates, container image updates, secret management (no secrets in front-end code or public repositories, Annex 20) and TLS renewal through documented procedures. Infrastructure is described as code in the First Party's repositories.
