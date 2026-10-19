# ADR-023: Observability and analytics

- **Status:** Accepted (Executor decision) for error monitoring (GlitchTip, self-hosted), infrastructure monitoring (Grafana, Uptime Kuma) and our own events table for reports. No product analytics tool at launch. The First Party confirms that GlitchTip is an acceptable "equivalent" to Sentry (Annex 17).
- **Annex reference:** 16 (reports, events analytics), 17 (Sentry or equivalent, PostHog or equivalent after approval, Grafana, Uptime Kuma), 19.12, 20.15, 25, 28, 34
- **Type:** Open (First Party confirmation of the equivalent tool). Our technical selection for the rest.

## Context
Errors, performance, failures and costs must be monitored, with alerts for failures and abnormal activity. The admin dashboard shows reports (users, listening hours, most-read and most-listened content, searches, downloads, plan usage, completion rates, share of published content, radio data) and exports them. A unified events plan covers apps, web and related systems, without sending sensitive personal data to analytics tools without need or consent. Error reports can contain personal data (device, IP address, user ID, text on screen), so where they are stored matters (Annex 28 and the PDPL). Hosting runs on a Riyadh provider (ADR-015), and extra hosts add recurring cost the First Party must approve (Annexes 26, 34).

## Options considered
Error monitoring, from public documentation (not tested by us):

| | GlitchTip, self-hosted | Sentry, self-hosted | Sentry, hosted by Sentry |
|---|---|---|---|
| Named in the annex | As an equivalent: needs First Party confirmation | Yes | Yes |
| Works with the Sentry SDKs for React Native, iOS, Android, Next.js and Node | Sentry-compatible API; to be proven in Phase 1 | Yes | Yes |
| Resources | Recommended 512 MB RAM (minimum 256 MB); PostgreSQL, optional Redis or Valkey | 4 CPU cores, 16 GB RAM plus 16 GB swap, 20 GB disk; many containers | None for us |
| Licence | MIT | Functional Source License (Apache 2.0 after two years) | Service |
| Vendor support | Community | None guaranteed for self-hosted | Vendor |
| Error data location | Our infrastructure | Our infrastructure | A third party; needs First Party approval and a data-location answer |
| Features we lose | No session replay or performance trace views | None | None |

Reports and product analytics:

| | Own events table for reports; no analytics tool at launch | Own events table plus a self-hosted analytics tool | External analytics tool only |
|---|---|---|---|
| Annex reports exact and exportable | Yes | Yes | Depends on the tool |
| Works if a tool is declined | Yes | Yes | No |
| Personal data leaving our systems | None | None | More |
| Funnels and retention | Not built | Yes | Yes |
| Extra hosting to run | None | A tool such as PostHog is documented as needing about 4 vCPU and 16 GB RAM and is officially unsupported by its vendor when self-hosted | None |

## Decision
- **Errors:** **GlitchTip, self-hosted**, with the Sentry SDKs in the mobile apps, public web, admin dashboard, API and workers. Sensitive data is scrubbed before sending. **Sentry** is the alternative named in the annex: hosted Sentry only if the First Party approves it and its data location, or self-hosted Sentry only if the First Party funds a host sized for it. Phase 1 proves, from each app, a test error with a readable stack trace (source maps for web and React Native) and a test crash from the mobile apps.
- **Infrastructure and uptime:** **Grafana** for metrics and dashboards, **Uptime Kuma** for uptime checks, as named in the annex, with alerts for failures, resource limits and cost. Structured JSON logs from every service, kept for an agreed period. These run on a small monitoring host, separate from the application hosts so an application outage does not take the monitoring down. Uptime Kuma should also check from outside the hosting location (a small VM in another location or with another provider) so a data-centre outage is visible.
- **Reports:** the Analytics and reports module records usage events (opens, searches, plays and listening seconds, downloads, plan activity) into our own PostgreSQL tables with a defined event plan. The dashboard queries pre-aggregated tables, and exports go to Excel or CSV.
- **Product analytics:** none at launch. If the First Party later wants funnels and retention, we propose a tool at that point, with its hosting cost, for approval under Annexes 17 and 34. Events would carry an anonymous or pseudonymous ID and no names, email addresses, notes or plan content, and web analytics would respect cookie consent.
- **Event plan:** one list of event names and fields, written once and used by all apps, versioned in the repository.

## Consequences
- The annex reports do not depend on a third-party tool.
- Error data stays in our infrastructure, which avoids a data-location question for error reports.
- GlitchTip is light enough to share a small monitoring host with Grafana and Uptime Kuma. Its sizing is confirmed in Phase 1. We run, update and back up the monitoring stack ourselves, without vendor support. Error history is not business data, so its backup is optional and its retention is agreed with the First Party.
- Own event storage grows with usage. We partition by month and roll up old events (ADR-012 jobs). A retention period is agreed with the First Party.
- If GlitchTip does not meet the Phase 1 checks, the fallback is hosted Sentry (needs approval) or self-hosted Sentry (needs a larger host).
- Notes, search text typed by a user and other free text are not sent to monitoring tools. Search statistics store normalized queries only where the privacy policy allows it.
- The monitoring host and its cost are listed in the First Party's list of external operational expenses (Annex 26, item 24).

## Limits of the evidence
Resource figures, licences and features come from public documentation and comparison articles. We did not install or load-test GlitchTip, Sentry or any analytics tool, and we have not verified GlitchTip's SDK behaviour on React Native, iOS or Android. Phase 1 checks that.
