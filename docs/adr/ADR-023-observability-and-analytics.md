# ADR-023: Observability and analytics

- **Status:** Accepted (Executor decision) for error monitoring and infrastructure monitoring. Product analytics tool is Open and needs First Party approval (Annex 17, 34).
- **Annex reference:** 16 (reports, events analytics), 17 (Sentry, PostHog, Grafana, Uptime Kuma), 19.12, 20.15, 25
- **Type:** Open

## Context
Errors, performance, failures and costs must be monitored, with alerts for failures and abnormal activity. The admin dashboard shows reports (users, listening hours, most-read and most-listened content, searches, downloads, plan usage, completion rates, share of published content, radio data) and exports them. A unified events plan covers apps, web and related systems, without sending sensitive personal data to analytics tools without need or consent.

## Options considered
| | Own events table for reports, plus an external tool for product analytics if approved | External analytics tool only | Own events only |
|---|---|---|---|
| Reports in the admin dashboard are exact and exportable | Yes | Depends on the tool and its limits | Yes |
| Works if the analytics tool is declined or removed | Yes | No | Yes |
| Personal data leaving our systems | Minimal | More | None |
| Product analytics (funnels, retention) | Yes, with the tool | Yes | We would have to build it |

## Decision
- **Errors:** Sentry or an equivalent, in all apps and the backend. Sensitive data is scrubbed before sending. Self-hosting versus a hosted account is decided with the First Party because of data location (ADR-015).
- **Infrastructure and uptime:** Grafana for metrics and dashboards, Uptime Kuma for uptime checks, as named in the annex, with alerts for failures, resource limits and cost. Structured JSON logs from every service, kept for an agreed period.
- **Reports:** the Analytics and reports module records usage events (opens, searches, plays and listening seconds, downloads, plan activity) into our own PostgreSQL tables with a defined event plan. The dashboard queries pre-aggregated tables, and exports go to Excel or CSV.
- **Product analytics:** PostHog or equivalent only after First Party approval. Events carry an anonymous or pseudonymous ID and no names, email addresses, notes or plan content. Web analytics respect cookie consent.
- **Event plan:** one list of event names and fields, written once and used by all apps, versioned in the repository.

## Consequences
- The annex reports do not depend on a third-party tool.
- Own event storage grows with usage. We partition by month and roll up old events (ADR-012 jobs). A retention period is agreed with the First Party.
- A monitoring stack is one more thing to run. It lives outside the application hosts so an outage of the application does not take down the monitoring (ADR-015).
- Notes, search text typed by a user and other free text are not sent to analytics tools. Search statistics store normalized queries only where the privacy policy allows it.
