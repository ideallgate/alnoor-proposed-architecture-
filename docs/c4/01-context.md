# C4 level 1: System context

Who uses Noor and which external systems it depends on. External services marked "to be chosen" are not yet selected; they are listed as roles.

```mermaid
C4Context
  title System context: Noor in the Prophetic Sunnah
  Person(reader, "Reader / listener", "Reads hadith, listens to audio with synced text, searches, follows plans, listens to Radio Noor")
  Person(staff, "Editor, reviewer, scholar, admin", "Creates and approves content through the approval cycle, manages audio, users and reports")
  System(noor, "Noor platform", "Mobile apps, public web, admin dashboard, API, workers, search, audio delivery")
  System_Ext(stores, "App stores and push services", "Distribute the apps; deliver push notifications (APNs, FCM)")
  System_Ext(mail, "Email service (to be chosen)", "Account and notification email")
  System_Ext(cdn, "CDN and WAF (to be chosen)", "Audio delivery, edge protection")
  System_Ext(obs, "Monitoring services", "Sentry for errors; Grafana and Uptime Kuma for infrastructure; analytics tool to be approved")
  Rel(reader, noor, "Uses", "HTTPS")
  Rel(staff, noor, "Manages content and users", "HTTPS, 2FA")
  Rel(noor, stores, "Sends push notifications through")
  Rel(noor, mail, "Sends email through")
  Rel(noor, cdn, "Publishes audio behind")
  Rel(noor, obs, "Reports errors and metrics to")
```

Decisions: [ADR-015](../adr/ADR-015-hosting-and-infrastructure.md) (hosting, CDN and WAF), [ADR-001](../adr/ADR-001-backend-framework.md).
