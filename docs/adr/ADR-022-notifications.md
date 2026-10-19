# ADR-022: Notifications

- **Status:** Accepted (Executor decision) for the design. The email service is Open and needs First Party approval (Annex 34).
- **Annex reference:** 10.11, 11 (notifications), 12, 14.6, 34 (external services), 20
- **Type:** Open

## Context
General notifications, content or hadith of the day, plan reminders, daily portion reminders, content notifications, scheduling from the admin dashboard, and management of their content and status. Notifications due at a set time must not be delayed by heavy jobs (ADR-012).

## Options considered
| | Firebase Cloud Messaging for both platforms | Direct Apple (APNs) and Google (FCM) integrations | Hosted notification service |
|---|---|---|---|
| Platforms covered | Android directly, iOS through APNs | Both, directly | Both |
| Recurring cost | None for the push channel itself | None | Per-message or per-user fees needing approval |
| Code we maintain | One integration | Two | One, plus vendor dependency |
| Data leaving our systems | Device tokens and message text | Same | Same, plus more at the vendor |

## Decision
- **Channel:** push through Firebase Cloud Messaging for Android and iOS (iOS delivery goes through Apple's service). It sits behind a port in the Notifications module, so it can be replaced without changing other code.
- **Scheduled notifications:** created in the admin dashboard, stored in PostgreSQL and sent by pg-boss jobs on their own queue (ADR-012), per user time zone where the content calls for it.
- **Personal plan reminders:** scheduled on the device as local notifications, and refreshed after each sync. They work offline, cost nothing to send and need no server push for each reminder. The server holds the plan settings. If the device cannot schedule local notifications, the user can choose server push for reminders instead.
- **Content:** notification text is managed content with a status, and goes through the approval cycle when it quotes hadith text (ADR-004).
- **Token handling:** device tokens are stored per device, removed when the provider reports them invalid, and deleted on logout or account deletion.
- **Email:** account and notification email goes through an email service chosen with the First Party. It is not selected here because it is a recurring cost under Annex 34.

## Consequences
- A message to a device only reaches it if the device's push token is valid and the user allowed notifications; delivery is not guaranteed by any provider. We show a "sent" and "failed" status for our side only.
- Local reminders depend on the OS allowing scheduled notifications; some Android makers restrict background work, which we test.
- Firebase is a Google service, so it is an external service under Annex 34. It goes on the list of external services (Annex 26.22) and needs the First Party's approval before we use it.
