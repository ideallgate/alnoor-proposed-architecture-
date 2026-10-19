# ADR-019: Audio processing and audio-text alignment

- **Status:** Accepted for the processing pipeline, the data model and the manual sync tool. Proposed for automatic alignment (evaluation planned in Phase 3).
- **Annex reference:** 7 (synchronization), 8 (processing tool, waveform), 17 (FFmpeg), 19.10, 28 (no external AI services)
- **Type:** Open

## Context
Audio arrives in two forms: a separate file per hadith or narration, or one long file with many clips. Sync must be at sentence level at minimum and word level where possible, correctable by hand in the admin dashboard, stored in the database, tied to the text version, and flagged for review when the text changes in a way that affects it.

Annex 28 forbids entering project content into external services the First Party has not approved and forbids using it to train or improve AI models.

## Options considered
| | Manual sync tool first, automatic alignment as an assistant | Automatic alignment only | Manual only |
|---|---|---|---|
| Meets the annex (manual correction is mandatory) | Yes | No | Yes |
| Accuracy on vocalized classical Arabic | Scholar-checked | Unknown until tested | Scholar-checked |
| Effort per clip | Reduced where automatic alignment works | Lowest if it works | Highest |
| Content leaves our systems | No | Not if self-hosted | No |

## Decision
1. **Processing pipeline** (queue workers, ADR-012): volume normalization, silence trimming at the ends, a streaming version, a download version, original kept. FFmpeg, named in the annex.
2. **Admin audio tool:** waveform display with draggable start and end markers for long files (Case Two), bulk import by agreed identifiers for separate files (Case One). A waveform library such as wavesurfer.js is expected; confirmed in Phase 2.
3. **Sync data model:** a sync point links an audio time to a **text token** (ADR-005) of a **specific text version** (ADR-004). Sentence-level points are required; word-level points are optional per clip. A clip whose text changes in a way that affects its tokens is flagged "needs review" and its published sync stays in use until a new version is approved.
4. **Manual correction first.** The editor plays the clip and adjusts points by hand. This is the baseline that satisfies the annex.
5. **Automatic alignment is an assistant, not a requirement.** We evaluate self-hosted tools on a sample of the First Party's real audio in Phase 3. It must run on our own workers, with no content sent to an external service (Annex 28). We adopt it only if scholars confirm the accuracy is good enough on vocalized Arabic.

## Consequences
- The word-level promise stays conditional ("when possible", Annex 7). We will not claim it works for all clips until tested on the real audio.
- Real audio samples and their texts from the First Party are needed early to test the pipeline and the alignment evaluation.
- Re-processing an original (for example a new normalization setting) is a queue job and does not change the published URL until the new version is approved.
