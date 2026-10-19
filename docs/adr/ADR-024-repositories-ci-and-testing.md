# ADR-024: Repositories, CI/CD and testing

- **Status:** Accepted (Executor decision). The Git host and CI service are set with the First Party, who must own or control the repositories (Annex 24).
- **Annex reference:** 17 (Docker, CI/CD, environments), 23 (bi-weekly demos), 24 (repositories, tests), 25, 26
- **Type:** Open

## Context
Code lives in Git repositories owned or controlled by the First Party from day one, with a regular history, pull requests and review, no secrets in the repository, a branching strategy, migration files, automated tests for critical paths (approval cycle, publishing, search, audio playback, main account and plan functions), no release to production without passing the test environment, and CI/CD for orderly deployment. Test builds of the apps go out at least every two weeks.

## Options considered
| | One repository for all parts (monorepo) | One repository per part |
|---|---|---|
| Shared types and API client | Direct | Published as packages |
| Atomic change across API, web, admin and apps | One pull request | Several, in order |
| Handover | One clone, one history | Several to track |
| Access control per part | Coarser | Finer |

## Decision
- **Monorepo** with workspaces: API and workers, web, admin, mobile, shared packages (types, generated API client, event plan), infrastructure files, documentation (these architecture records included). A single package manager and task runner for the workspace.
- **Branching:** short-lived branches, pull requests with review, a protected main branch that always builds and passes tests, tagged releases.
- **Pipeline:** on each pull request: lint (including the module-boundary rules of ADR-010), type check, unit and integration tests against PostgreSQL in a container, OpenAPI contract check (ADR-021), dependency and image scanning. On merge: build and publish container images, deploy to the test environment, run smoke and end-to-end tests. Production deploys promote the same images from test, by a manual approval (ADR-015).
- **Tests on the critical paths** the annex names: approval cycle and publishing (including that unpublished content never reaches a public endpoint), search (the Arabic variant cases from the benchmark become regression tests), audio playback and sync, accounts and permissions, plans. Web and admin end-to-end tests with Playwright. Mobile end-to-end tests with a device-level tool (chosen in Phase 1). Load tests before acceptance (Annex 18).
- **Spec-driven:** the OpenAPI contract and the module interfaces are written before implementation, and tests are written against them.
- **Environments:** local development with Docker Compose, then shared testing and production, each built from the same images with different configuration (ADR-015). Mobile test builds through TestFlight and Google Play Internal Testing.
- **Deliverables:** the Docker files, CI/CD configuration, migration files, OpenAPI document and these records are in the repository (Annex 26).

## Consequences
- One history and one toolchain make handover simpler. A large repository needs build caching so CI stays fast.
- Mobile store builds need accounts and signing keys that belong to the First Party from the start (Annex 26.25).
- CI minutes and any paid service are external costs reported under Annex 34.
- Which Git host and CI service the First Party uses affects the pipeline syntax, not the structure above.
