# ADR-020: Authentication and security controls

- **Status:** Accepted (Executor decision) for the mechanism. Sign-in methods for beneficiaries are Open with the First Party.
- **Annex reference:** 4.6, 4.8 (browse without an account, sync on login), 14.1, 20 (security and privacy, PDPL, OWASP, MASVS), 24.5
- **Type:** Open

## Context
Public content is open without an account. An account is needed to sync favorites, plans, progress and personal data. Admin users need two-factor authentication, role- and data-level permissions (ADR-007), an audit log, API rate limiting, protection against malicious requests, and compliance with OWASP Top 10 (backend), OWASP MASVS (mobile) and the technical controls of the Personal Data Protection Law (PDPL).

## Options considered
| | Built into the API | External identity provider (self-hosted, for example Keycloak) | Hosted identity service |
|---|---|---|---|
| Control over data location (PDPL) | Full | Full | Depends on the provider |
| Extra service to run | None | One more stateful service | None, but a recurring cost needing approval (Annex 34) |
| Fit with our permission model (ADR-007) | Direct | Needs mapping | Needs mapping |
| Handover | Part of the API | Another system to learn | Vendor dependency |

## Decision
Authentication is a module of the API (Identity and permissions, ADR-010), not a separate service.

- **Web and admin:** HTTP-only, secure, same-site session cookies, with CSRF protection.
- **Mobile apps:** short-lived access tokens with rotating refresh tokens, stored in the platform's secure storage (Keychain, Keystore).
- **Passwords:** hashed with a memory-hard algorithm (Argon2id). Login throttling and lockout through the rate limiter (Redis, ADR-012).
- **Admin 2FA:** mandatory, with time-based one-time codes (TOTP) and recovery codes. Optional for beneficiaries.
- **Authorization:** CASL permissions by function and by data (book, section, content), enforced in the API, never only in a client (ADR-007).
- **Audit log:** sensitive admin operations are recorded with user, time, item, before and after. It is kept apart from content versions (ADR-004).
- **Secrets:** never in front-ends or repositories. Environment variables or a secrets manager, rotated on handover.
- **Transport and storage:** HTTPS everywhere, encrypted disks and backups, field-level encryption only for data that needs it.
- **Request protection:** schema validation (ADR-008), rate limits, WAF at the edge (ADR-015), dependency and image scanning in CI.
- **OWASP and MASVS:** the OWASP Top 10 and MASVS checklists are acceptance items. The security scan before launch (Annex 20.12) uses them.

Sign-in methods for beneficiaries (email and password, phone number, or sign-in with Apple and Google) are decided with the First Party. If a third-party or social sign-in is offered on iOS, Apple's App Store Review Guideline 4.8 requires the app to also offer an equivalent privacy-preserving sign-in option, and Sign in with Apple is the standard way to meet it. We will check the current wording of the guideline when the sign-in methods are chosen. Account data collected is kept to what sync needs.

## Consequences
- No extra service for identity, and user data stays in the application database under our PDPL controls.
- The team maintains security-sensitive code that a hosted provider would otherwise carry. Mitigations: well-reviewed libraries, no custom cryptography, tests on the authentication and permission paths, and the pre-launch security scan.
- Which personal data is collected, retention periods and consent texts depend on the First Party's privacy policy (Annex 25). We implement the technical controls once those are provided.
- Components we already own (for example an existing authentication and admin foundation) must be disclosed to the First Party in advance and licensed as Annex 27 requires, and must not create a mandatory dependence on us.
