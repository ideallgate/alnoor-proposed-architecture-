# C4 level 1: System context

Who uses Noor and which external systems it depends on. The edge, the audio CDN and the monitoring stack are part of the platform (we operate or select them), so the only external systems are the push services and an email service that is still to be chosen. Names match the Structurizr model.

```mermaid
C4Context
  title System context: Noor in the Prophetic Sunnah
  Person(learner, "Beneficiary", "Reads, searches and listens to hadith; follows plans; listens to Radio Noor")
  Person(editor, "Content team and administrators", "Enter and edit content, upload and sync audio, submit for review; manage users, radio and reports")
  Person(scholar, "Scholars and approvers", "Review and approve content in the approval cycle")
  Person_Ext(radioListeners, "Third-party radio listeners", "Optional: listen to the live stream in any stream-capable player, only if the First Party chooses Radio Option B")
  System(noor, "Noor platform", "Mobile apps, web, admin dashboard, API, search, audio, radio, notifications")
  System_Ext(push, "Apple and Google push services", "Deliver notifications to devices")
  System_Ext(mail, "Email service (to be chosen)", "Account and notification email")
  Rel(learner, noor, "Reads, searches, listens", "iOS, Android, web")
  Rel(editor, noor, "Manages content and audio", "Admin dashboard")
  Rel(scholar, noor, "Reviews and approves", "Admin dashboard")
  Rel(radioListeners, noor, "Listen to the live stream (Option B)", "HTTPS, audio stream")
  Rel(noor, push, "Sends notifications", "HTTPS")
  Rel(noor, mail, "Sends email through", "HTTPS")
```

Decisions: [ADR-015](../adr/ADR-015-hosting-and-infrastructure.md) (hosting), [ADR-025](../adr/ADR-025-edge-waf-and-cdn.md) (edge, WAF and CDN), [ADR-023](../adr/ADR-023-observability-and-analytics.md) (monitoring), [ADR-022](../adr/ADR-022-notifications.md) (push and email), [ADR-001](../adr/ADR-001-backend-framework.md).
