# ADR-016: Mobile apps: React Native

- **Status:** Accepted (Executor decision, from the options Annex 17 lists)
- **Annex reference:** 4, 6, 9, 17 (React Native or Flutter), 18 (50 MB target, last two major OS versions), 22 (accessibility)
- **Type:** Open (our selection between the two named options)

## Context
One shared codebase for iOS and Android, full Arabic and RTL support, correct display of vocalized Arabic, a background audio player with lock-screen control, offline downloads, local use without an account, and accessibility with VoiceOver and TalkBack. The annex names React Native or Flutter.

## Options considered
| | React Native | Flutter | Two native apps |
|---|---|---|---|
| Named in the annex | Yes | Yes | No: not a shared codebase |
| Language and team fit | TypeScript, shared with API, web and admin | Dart, a separate language and toolchain | Swift and Kotlin, two codebases |
| Share types and API client with web and admin | Direct (generated from the OpenAPI contract, ADR-008) | Needs a separate generated client | Separate clients |
| Arabic text with vocalization | Uses the platform's text engine | Uses its own text renderer | Platform engine |
| Audio, background playback, lock screen | Maintained community libraries, native modules when needed | Plugins | Native APIs |
| Handover to another supplier | Large TypeScript talent pool | Smaller pool | Two skill sets |

## Decision
React Native with TypeScript for both apps. Whether to use Expo tooling or the bare workflow is decided in Phase 1, after a prototype proves the three risky parts below. Types and the API client are generated from the OpenAPI contract and shared with web and admin.

Phase 1 must prove, on real devices and before the design is built out:
1. Vocalized Arabic renders correctly at large font sizes, in night mode, with diacritics not overlapping, and with word-level highlighting during playback.
2. Background playback and lock-screen controls work on both platforms with the chosen audio library.
3. Offline downloads survive app restarts and app updates.

## Consequences
- Benefits: one language across the platform, one team, shared contract and types.
- Trade-offs we accept: native modules may be needed for audio and downloads; React Native and library upgrades need ongoing care, especially when a new OS version ships (the 12-month warranty covers these, Annex 33).
- If the Phase 1 prototype fails test 1 or 2, we report it to the First Party and use the Flutter option named in the annex rather than work around it.
- Initial app size is tracked against the 50 MB target from the first build.
- Accessibility (VoiceOver, TalkBack, system font scaling) is tested on every release, not at the end.
