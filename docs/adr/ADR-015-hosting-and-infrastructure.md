# ADR-015: Hosting and infrastructure: Ubuntu hosts, Docker Compose first, Kubernetes when needed

- **Status:** Accepted (Executor decision) for the hosting model. Provider, country and region are **Open**: Annex 19 says they are set with the First Party under the approved regulatory requirements.
- **Annex reference:** 17 (Docker, CI/CD, separate environments, monitoring), 18 (capacity, 99.5% availability), 19 (hosting and operations), 20 (security), 21 (backup and restore), 26 (handover, Docker files, guides)
- **Type:** Open for provider and region. Our technical selection for the rest.

## Context
Annex 19 lists what the infrastructure must provide: application servers, a database, separate audio storage, a CDN, progressive audio streaming, a load balancer where needed, a WAF or equivalent, TLS, separate development/testing/production environments, heavy tasks isolated from the main servers, resources that grow without rebuilding the system, monitoring, and backups separate from production. Section 26 requires that the First Party, or another supplier, can operate the system without depending on us.

Targets that shape the design (Section 18): 1,500 concurrent sessions at peak, 10,000 registered users, at least 1,500 hours of audio and 2 TB of storage (expandable), and 99.5% monthly availability, which is about 3.6 hours of downtime in a 30-day month.

## Options considered
| | Ubuntu hosts + Docker Compose | Kubernetes from day one | Managed platform (PaaS / container service) |
|---|---|---|---|
| Fits the annex list | Yes | Yes | Yes |
| Provider independence (handover, Section 26) | High: any provider that offers Ubuntu VMs | High, but each provider's Kubernetes differs in networking, storage and load balancing | Lowest: tied to one provider's service |
| Operating effort for the First Party's team | Low: files and commands most teams already know | High: cluster upgrades, networking, storage, a skilled operator | Low |
| Fit for our topology (one API, workers, one database, one search node) | Good | More machinery than the workload needs at launch | Good |
| Scaling | Add or resize VMs, split roles across hosts; no automatic scaling | Automatic scaling, rolling updates | Automatic, provider-defined |
| Cost | Lowest | Higher (control plane and spare capacity) | Highest per unit |
| Main risk | Manual failover and updates unless scripted | Complexity and cost not justified at this size | Provider lock-in; may need First Party approval as a changed core technology |

## Decision
**Ubuntu LTS virtual machines running Docker, deployed with Docker Compose at launch.** The same container images run in development, testing and production. When scale or availability needs exceed what Compose on a few hosts can give, we move to Kubernetes without changing application code.

Provider: **Hetzner, or any other provider the First Party approves** (including AWS or Azure). The design uses only Ubuntu VMs, S3-compatible object storage and a block volume, so it does not depend on one provider. Provider, country and region are decided with the First Party.

### Mapping to Annex 19
| Annex 19 item | Our approach |
|---|---|
| 1, 2 Application servers, database | API, public web and admin on an application host; PostgreSQL on its own host or volume (ADR-002) |
| 3 Separate audio storage | S3-compatible object storage, not the application disks ([ADR-018](ADR-018-audio-storage-and-delivery.md)) |
| 4, 5 CDN, progressive streaming | CDN in front of object storage with HTTP range requests; signed or temporary URLs for private content (Section 20, items 13-14) |
| 6 Load balancer | Provider load balancer or a reverse proxy when more than one application host exists |
| 7 WAF or equivalent | A CDN or edge service with WAF rules, or an equivalent the First Party approves. We understand Hetzner does not offer a WAF or CDN product (to be confirmed with the provider), so on that provider this would be an external service |
| 8 TLS | Automated certificate issue and renewal (systemd timer or proxy built-in), not the application queue (ADR-012) |
| 9 Separate environments | Development, testing and production, each from the same images and different configuration and secrets |
| 10 Isolate heavy tasks | Workers (audio, alignment, indexing, notifications) run as separate containers on a separate host from the API (ADR-010, ADR-012) |
| 11 Grow without rebuilding | Resize VMs and volumes; move roles to more hosts; object storage grows independently; Kubernetes path below |
| 12 Monitoring | Grafana and Uptime Kuma for resources, uptime and cost; Sentry for errors. All are named in Annex 17 |
| 13 Separate backups | See below |

### Launch topology (indicative, sizing to be set by performance tests)
- **Application host:** reverse proxy, API, public web, admin dashboard, Redis (cache and rate limiting only).
- **Worker host:** pg-boss workers, FFmpeg and alignment jobs. Isolated from the API as Section 19 item 10 requires.
- **Database host:** PostgreSQL 16 with its own volume.
- **Search host:** OpenSearch (ADR-013). It needs about 2 GiB of memory with a 1 GiB heap in our test, so it is sized separately.
- **Object storage and CDN:** managed, separate from all of the above.
- Production and non-production environments run on separate hosts.

### Backups (Annex 21)
- Daily database backup, plus continuous WAL archiving if the First Party wants point-in-time restore.
- Backups stored in a different location and, preferably, a different account or provider from production.
- Audio and content files copied periodically to a second storage location, with object versioning where available.
- OpenSearch is not a backup source: it can be rebuilt from PostgreSQL (ADR-004, ADR-013). We tested a full reindex of the real corpus at about 17 seconds.
- Restore documented, and a restore test at least every three months while we operate it.

### Moving to Kubernetes
We do not need it at launch. We move when one of these is true, not before:
- We need automatic scaling or zero-downtime rolling deploys that scripted Compose on several hosts cannot give.
- Availability evidence shows the 99.5% target is at risk from single-host roles.
- The number of services or teams makes manual host management the bigger risk.

To keep that move cheap: every service runs from a container image, takes configuration from environment variables, exposes health endpoints, and keeps state only in PostgreSQL, Redis (cache), search and object storage. Modules that need to be extracted follow ADR-010.

## Consequences
- Provider-independent and easy to hand over: a Compose file and an Ubuntu host are enough to run it.
- 99.5% availability on a single host per role depends on fast, scripted rebuild and restore. We must demonstrate it in the restore test and the performance tests. If the First Party wants a stronger guarantee, add a second application host behind a load balancer, which is within this design.
- No automatic scaling at launch.
- Infrastructure as code (host setup, Compose files, CI/CD deploy) goes in the First Party's repositories with the Docker files (Section 26). The tool is not chosen yet.
- On Hetzner specifically: if the provider does not offer a WAF and a CDN with the capabilities Section 19 needs, they come from an external service, which must be on the First Party's approved list.
- Managed PostgreSQL is used if the chosen provider offers it and the First Party approves; otherwise we run it ourselves with the backups above.

## Open points for the First Party
- Provider, country and cloud region, in line with PDPL and any other regulatory requirements (Section 19). Where user and audio data may be stored and whether cross-border transfer is allowed is a legal question for the First Party. We are not giving legal advice.
- Whether an external CDN and WAF service is acceptable.
- Retention period for historical backups (Section 21 refers to the approved operational policy).
- Whether the First Party wants a stronger availability design than one host per role.

## Limits of the evidence
No infrastructure was benchmarked. Sizing, the 99.5% claim and the 1,500-concurrent target are to be shown in the performance tests required before acceptance (Section 18). The benchmark data we do have (ADR-009, ADR-012, ADR-013) comes from one laptop.
