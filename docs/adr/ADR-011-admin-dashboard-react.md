# ADR-011: Admin dashboard: React + TypeScript

- **Status:** Accepted (Executor decision)
- **Annex reference:** 14 (admin dashboard), 17 (names Vue 3 + TypeScript), 8, 13
- **Type:** Open

## Context
The admin dashboard covers content management, an Arabic editor that preserves vocalized text, a waveform tool, the approval cycle, bulk import and reports. We already have a proven React-based foundation for auth, RBAC, audit log and admin panel.

## Options considered
| | Vue 3 + TypeScript | React + TypeScript |
|---|---|---|
| Existing foundation | Admin UI rebuilt | Reused |
| Consistency with web and mobile | A different UI model from the public web platform and React Native | One component model across admin, web and mobile |
| Rich Arabic editor | TipTap, ProseMirror | Same, plus Lexical and Slate |
| Waveform tool | wavesurfer.js, framework-agnostic | Same |
| Admin UI libraries | Element Plus, Vuetify | MUI, React Admin, Refine |
| Public web platform with SEO | Nuxt | Next.js |
| Talent pool for future maintainers | Smaller | Larger |
| Learning curve | Simpler, more official conventions | More choices to make |

## Decision
React + TypeScript for the admin dashboard.

## Consequences
- Benefits: reuse of the proven foundation, one UI approach across admin, web and mobile, more of the schedule spent on the hadith model, approval cycle, search and audio sync.
- Trade-off we accept: more libraries to choose and keep consistent; the "one component model" advantage assumes the mobile app is React Native.
- Type safety across admin, web and mobile comes from the generated OpenAPI client (ADR-008), shared as a package in the monorepo (ADR-024).
