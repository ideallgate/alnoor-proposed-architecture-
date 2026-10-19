# ADR-014: Radio Noor: scheduled radio core with two delivery options

- **Status:** Proposed. Both options are supported by the design. The First Party chooses the delivery option.
- **Annex reference:** 12 (Radio Noor), 8 (audio processing), 17, 19.5 (progressive streaming), 18
- **Type:** Open (our design); the delivery option depends on the First Party's expectation of "continuous broadcast"

## Context
Section 12 asks for continuous broadcast of approved audio, use of the existing library, playlists, scheduling, ordering, display of the current and next item, management from the control panel, and 24/7 operation. It does not say whether the broadcast must be consumable by standard radio players or only inside the Noor app and web platform.

Only published audio may be broadcast (ADR-004). Heavy work stays in workers (ADR-010, ADR-012).

## Design: one radio core, two delivery options
The **radio module** owns playlists, the schedule, ordering and the "now playing / next" timeline, and is managed from the admin dashboard. It is the single source of truth for both options. Items are drawn from published audio only; an item that is unpublished or withdrawn is skipped, and the timeline is recalculated.

### Option A: Scheduled radio in the app and website (baseline)
- The API returns the current item, its offset, the next item and the server time. Clients play the item from the CDN at that offset and use the server time to correct clock differences.
- Clients prefetch the next item for gapless transitions and re-check at item boundaries.
- Everyone hears the same item at about the same moment, within clock-correction accuracy.

### Option B: Live stream (extension)
- A playout service (for example Liquidsoap) reads the same schedule and produces one continuous audio stream. A streaming server (for example Icecast) serves it, with the CDN in front.
- Standard radio players and third parties can listen. The Noor apps can also play this stream. Every listener hears the same stream, so differences between listeners are only buffering delays.
- Adds a fallback playlist for schedule gaps, stream metadata for the current item, and monitoring and automatic restart.

## Options considered
| | A: Scheduled radio (in-app) | B: Live stream |
|---|---|---|
| Meets Section 12 as we read it | Yes | Yes |
| Listeners outside the Noor apps (standard radio players, rebroadcast) | No | Yes |
| Extra 24/7 services | None beyond the API and CDN | Playout service and streaming server |
| Listener synchronization | Within clock-correction accuracy | One stream; listeners differ only by buffering delay |
| Failure modes | A client or API issue affects one listener | A playout or stream failure affects all listeners; needs failover |
| Seeking or joining mid-item | Natural | Joins the live position |
| Audio bandwidth | CDN, per listener | CDN, per listener (about the same) |
| Admin dashboard and schedule logic | Radio core | Same radio core |
| Effort and schedule impact | Baseline | Additional; to be estimated and agreed with the First Party |

## Decision
Build the radio core and Option A as the baseline. Design the core so Option B is a delivery add-on: the playout service consumes the same schedule through the same module interface. The First Party chooses which option(s) to enable. If Option B is requested, its schedule and cost impact are agreed before work starts.

## Validation required
- The First Party confirms whether Radio Noor must be consumable outside the Noor apps.
- We validate scheduling behavior ourselves: item boundaries, gapless transitions, joining mid-item, a playlist edited while live, an item unpublished while scheduled, and clock differences between devices.

## Consequences
- Benefits: the client can choose without changing the admin experience or the radio data model; the baseline needs no extra 24/7 service.
- Trade-off we accept: supporting Option B later still adds services and operations (playout, streaming server, failover monitoring), and that has to be planned and agreed, not assumed.
