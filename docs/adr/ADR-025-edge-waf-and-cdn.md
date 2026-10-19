# ADR-025: Edge: WAF for web and API, global CDN for audio

- **Status:** Accepted (Executor decision) for the split and for the self-hosted WAF. The **CDN vendor is Open**: it is selected with the First Party once audience size, budget and approvals are known.
- **Annex reference:** 17 (core technology changes), 19 (items 4 CDN, 6 load balancer, 7 WAF, 8 TLS), 20 (items 7, 8, 11, 13, 14), 27 (licences of components), 28 (no project data to unapproved services), 34 (external services and costs)
- **Type:** Open (CDN vendor). Our technical selection for the rest.

## Context
Annex 19 requires a CDN (item 4) and a WAF or equivalent (item 7). The platform is for a Saudi Arabian First Party and is hosted in Riyadh (ADR-015). The audience is Muslims worldwide, so audio must reach distant listeners quickly (start within 2 seconds on 4G, Annex 18). The Executor also does not want login and user-data traffic to pass through a third party that terminates TLS without First Party approval (Annexes 20, 28, 34, and the Saudi PDPL, whose transfer rules the First Party's counsel must confirm).

The two kinds of traffic are different:
- **Audio and static media:** large, public once published, cacheable, no logins or user data in the request. This is where a global CDN helps most.
- **Web, API and login traffic:** small, personal, not cacheable. It carries sessions, tokens and user data.

## Options considered
| | A. One managed CDN and WAF in front of everything | B. Self-hosted edge only | C. Split: self-hosted WAF for web and API, managed CDN for audio only |
|---|---|---|---|
| Annex 19 item 4 (CDN) | Yes | Not strictly: one place, not a CDN | Yes |
| Annex 19 item 7 (WAF) | Yes, managed rules | Yes, our rules | Yes for web and API (ours); audio is protected by signed URLs and the CDN's rate rules |
| Third party sees login and user-data traffic | Yes: it terminates TLS for everything | No | No: only audio requests |
| Audio speed for distant listeners | Good | Depends on distance to Riyadh | Good |
| Web and API speed for distant users | Good for cached pages, no gain for personal calls | Distance to Riyadh | Distance to Riyadh |
| Volumetric DDoS | Absorbed by the vendor's network | Not absorbed by us; depends on the hosting provider | Audio flood absorbed by the CDN; web and API depend on the hosting provider |
| Work for us | Lowest | Highest: rule tuning, patching | Medium: WAF tuning for web and API only |
| Approvals needed | Vendor for all traffic | None beyond hosting | Vendor for audio traffic only |

## Decision
We select **option C**.

**Web and API (Riyadh):**
- A self-hosted edge in front of the web app and the API: **BunkerWeb** (Nginx with ModSecurity and the OWASP Core Rule Set), open-source edition only. It terminates TLS, applies WAF rules, rate limits and bot and IP rules, and routes to the API and Next.js. It runs in Docker Compose with the rest of the platform (ADR-015).
- Rules start in detection-only mode, are tested against our Arabic search queries and typical API use, and are switched to blocking only after false positives are fixed.
- The alternative if BunkerWeb does not meet our tests is plain Nginx with ModSecurity or Coraza and the OWASP Core Rule Set. Nothing else in the design depends on the product.
- Optional IP-reputation lists (for example CrowdSec) fetch data from an external service, so they stay off unless the First Party approves them.

**Audio and static media (global):**
- A **managed CDN** on its own hostname (for example `media.<domain>`), in front of the private object-storage origin (ADR-018). Only published audio is served, through short-lived signed URLs and HTTP range requests.
- **The vendor is not chosen.** Selection criteria: points of presence in Riyadh and in the regions where listeners are; validation of signed URLs at the edge or an equivalent that keeps the origin private; byte-range and large-file caching; cost per GB and per request, with a cap or alerts (Annex 34); where TLS is terminated and where logs are stored; contract terms on data processing; and the ability to leave without changing the application (only the hostname and signing method change).
- Candidates to request quotes from, not yet verified by us: a CDN offered by the First Party's chosen hosting provider, Bunny, Gcore, and Akamai as a premium comparison. The Executor has not shortlisted a CDN that would terminate TLS for the web and API traffic.
- Until the First Party picks the vendor, the same audio can be served from Nginx cache nodes in Riyadh for development, testing and the Saudi launch audience.

**Origin protection and DDoS:**
- The object-storage origin accepts requests only from the CDN or from our signed URLs.
- The web and API hosts accept public traffic only through the edge.
- Large volumetric attacks on the Riyadh hosts are handled by the hosting provider's network protection. A self-hosted WAF does not absorb them. We confirm what the chosen provider includes.

### Mapping to Annex 19
| Item | Our approach |
|---|---|
| 4 CDN | Managed CDN for audio and static media; vendor open |
| 6 Load balancer | The edge, or the provider's load balancer when there is more than one application host |
| 7 WAF or equivalent | BunkerWeb on web and API; signed URLs, hotlink and rate rules at the CDN for media |
| 8 TLS | Automated certificates at the edge and at the CDN hostname |

## Consequences
- Login and personal data never pass through a third-party TLS terminator. Only audio requests do.
- We own WAF rule tuning, updates and false-positive handling for web and API. This is real work and must be planned in Phase 1 and Phase 5.
- Web and API calls from far away reach Riyadh directly, so their latency is higher than with a global edge. We have not measured it. The 500 ms API target for 95% of requests is checked in the Phase 5 tests, from several regions. If it fails, we add read-only caching of public pages or a second region (trigger-based, as in ADR-015).
- BunkerWeb is licensed under the AGPL-3.0 and has a paid edition. We use the open-source edition unmodified and list the licence under Annex 27 and Annex 26 (item 23).
- A CDN vendor outside the hosting provider needs First Party approval with cost model and alternatives (Annex 34), and its logs and TLS location need the First Party's privacy review.

## Open points for the First Party
- Expected listener numbers by region and expected monthly listening hours, to size and price the CDN.
- Approval of the CDN vendor and a cost budget.
- Whether a third party terminating TLS for audio requests is acceptable, and where its logs may be stored.
- Whether IP addresses seen by a CDN outside the Kingdom raise a transfer question under the Saudi PDPL, and which other countries' privacy laws apply to listeners abroad. These are questions for the First Party's counsel; we are not giving legal advice.

## Limits of the evidence
Nothing here was benchmarked. We did not test BunkerWeb, its false-positive rate on Arabic search queries, or any CDN. CDN and WAF vendor information in this record comes from public pages and comparison articles, not from vendor confirmation or our own tests. Edge locations, signed-URL features, prices and licence terms must be confirmed in writing before approval.
