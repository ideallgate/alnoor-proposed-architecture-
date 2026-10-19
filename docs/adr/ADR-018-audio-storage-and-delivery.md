# ADR-018: Audio storage and delivery

- **Status:** Accepted (Executor decision). The hosting provider follows ADR-015. The CDN vendor is Open and is selected with the First Party ([ADR-025](ADR-025-edge-waf-and-cdn.md)).
- **Annex reference:** 8, 9 (offline), 17 (S3-compatible storage, CDN, FFmpeg), 18 (2 TB, playback within 2 s on 4G), 19.3-19.5, 20.13-14
- **Type:** Open

## Context
At least 1,500 hours of audio and 2 TB of initial, expandable storage. Playback must start within 2 seconds on a suitable 4G connection, play progressively without downloading the full file, and support offline downloads. Original files must not be reachable directly, and private content uses secure or temporary links.

For scale: 1,500 hours of uncompressed 16-bit 44.1 kHz stereo audio is about 0.95 TB (about 635 MB per hour). If originals are kept uncompressed, they alone use about half of the 2 TB, before processed versions.

## Options considered
| | S3-compatible object storage + CDN, progressive streaming | Adaptive streaming (HLS/DASH) | Files on application disks |
|---|---|---|---|
| Meets "progressive playback without full download" | Yes (HTTP range requests) | Yes | Possible, but couples storage to servers |
| Annex 19.3 "separate storage" | Yes | Yes | No |
| Complexity | Low | Higher: segmenting, playlists, player support | Low |
| Offline download | A single file per clip | Needs segment handling | A single file |
| Scales to 1,500 h and beyond | Yes | Yes | No |

## Decision
- **Storage:** S3-compatible object storage, private bucket, separate from application servers. The original file is kept untouched. Processed versions are stored beside it: a streaming version and a download version (Annex 8).
- **Delivery:** through a global CDN with HTTP range requests, on its own media hostname. The origin is private; the CDN fetches from it. The API issues short-lived signed URLs for playback, and longer-lived signed URLs for downloads. The audience is worldwide and the origin is in Riyadh, so the CDN matters for start time at a distance. Login and API traffic does not go through it. The CDN vendor is selected with the First Party ([ADR-025](ADR-025-edge-waf-and-cdn.md)).
- **Format:** a compressed streaming format that all supported iOS and Android versions and browsers play natively (AAC in an MP4 container, to be confirmed in Phase 1 with the audio library). Progressive playback is the baseline. Adaptive streaming is not built at launch; it can be added without changing the storage model.
- **Only published audio is served.** Signed URLs are issued only for audio whose version is published (ADR-004).
- Access to the original files is limited to the processing workers and authorized admin roles.

## Consequences
- Benefits: simple, cheap, and independent of the provider, since only the S3 API is used.
- Trade-off: no automatic bitrate switching on poor connections. The 2-second start target is measured in the Phase 5 performance tests, and adaptive streaming is the fallback if they fail.
- Withdrawn or unpublished audio stops being issued, but already-issued signed URLs stay valid until they expire, so lifetimes are kept short. Offline copies already on a device are removed on the next sync.
- Storage growth, egress and CDN cost are monitored and reported (Annex 19.12, Annex 34). CDN cost grows with listeners worldwide, so the First Party's expected audience and budget are needed before the vendor is chosen.
