# ADR-017: Public web platform: Next.js

- **Status:** Accepted (Executor decision; the annex does not name a web technology)
- **Annex reference:** 13 (web platform, SEO, direct links), 22, 25 (launch readiness)
- **Type:** Open

## Context
The web platform needs the library, search, reading, audio with synced text, plans for registered users, sync with the mobile app, direct links to hadiths and chapters, support for opening the app from a link, SEO for public pages, and responsive layouts.

## Options considered
| | Next.js (React) | Single-page app (Vite + React) | Server-rendered templates in the API |
|---|---|---|---|
| Search-engine indexing of public pages | Server rendering and static generation | Weak without extra work | Good |
| Direct links with fast first load | Yes | Slower first load | Yes |
| Share code with admin and mobile (React, TypeScript, API client) | Yes | Yes | No |
| Interactive reader and player | Yes | Yes | Heavier |
| Operations | One more Node container | Static files only | None extra |

## Decision
Next.js with React and TypeScript. Public pages (books, chapters, hadiths) are server-rendered or statically generated with metadata, sitemap and social preview. The interactive reader and player run as client components. The site talks to the API only (same contract as the apps).

Published content is cached and invalidated when a new version is published (ADR-004). Only published content is ever rendered.

## Consequences
- Benefits: SEO and direct links without a second stack, shared components and types with the admin dashboard.
- The web app needs its own container and cache. It adds one deployable to ADR-015 (Docker Compose, then Kubernetes if needed).
- Universal links (iOS) and app links (Android) require the site to serve the association files for the app; these are part of launch readiness (Annex 25).
- Cookie consent and analytics follow ADR-023.
