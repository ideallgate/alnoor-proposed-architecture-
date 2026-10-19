workspace "Noor in the Prophetic Sunnah" "C4 model: levels 1 to 3. Source of truth for the architecture diagrams. Work in progress, not a final version." {

    model {
        # ---- People -------------------------------------------------------
        learner = person "Beneficiary" "Reads, searches and listens to hadith; follows plans; listens to Radio Noor"
        editor = person "Content team and administrators" "Enter and edit content, upload and sync audio, submit for review; manage users, radio and reports"
        scholar = person "Scholars and approvers" "Review and approve content in the approval cycle"
        radioListeners = person "Third-party radio listeners" "Listen to the live radio stream in any stream-capable player (only if the First Party chooses Radio Option B)" "Optional"

        # ---- The system ---------------------------------------------------
        noor = softwareSystem "Noor platform" "Mobile apps, web, admin dashboard, API, search, audio, radio, notifications" {

            mobile = container "Mobile apps" "iOS and Android apps: library, search, audio with synced text, plans, radio" "React Native (ADR-016)" "Client"
            web = container "Public web app" "Responsive web platform for beneficiaries" "Next.js, React (ADR-017)" "Client"
            admin = container "Admin dashboard" "Arabic admin: content, audio sync, approval cycle, radio, reports" "React, TypeScript (ADR-011)" "Client"

            edge = container "Edge (WAF and reverse proxy)" "Terminates TLS for web and API traffic in Riyadh; WAF rules, rate limits, routing to the API and web app (ADR-025)" "BunkerWeb (Nginx, ModSecurity, OWASP CRS)" "Edge"
            mediaCdn = container "Media CDN (vendor to be selected)" "Global delivery of audio and static media from the private origin; short-lived signed URLs, byte ranges. No logins or user data pass through it (ADR-025, ADR-018)" "Managed CDN, selected with the First Party" "Managed"

            api = container "API" "Modular monolith. REST API with OpenAPI contract, business rules, permissions" "Node.js, Express, TypeScript (ADR-009, ADR-010)" {

                identity = component "Identity and permissions" "Accounts, roles, 2FA, audit log. Every module asks it for authorization (CASL)" "Module (ADR-007)"
                content = component "Content" "Books, chapters, hadith, narrations, narrators, explanations, classification trees" "Module (ADR-004, 005, 006)"
                approval = component "Approval and versions" "Draft, review and publish cycle; row-per-version with a published pointer. Shares transactions with Content on purpose" "Module (ADR-004)"
                library = component "Library API" "Read endpoints for apps and web: browse, hadith screen, navigation" "Module"
                searchmod = component "Search" "Query building, suggestions, highlighting, indexing requests" "Module (ADR-013)"
                audiomod = component "Audio" "Audio records, segments, text-audio sync points, signed playback URLs" "Module"
                plans = component "Plans and progress" "Memorization, review and listening plans; progress and bookmarks" "Module"
                notifications = component "Notifications" "Reminders and scheduled notifications" "Module"
                radiomod = component "Radio" "Playlists, schedule, now-playing and next timeline (single source of truth for Option A and B)" "Module (ADR-014)"
                bus = component "Event bus and job publisher" "In-process events between modules; enqueues pg-boss jobs in the same transaction as the change" "Module (ADR-010, ADR-012)"
                analytics = component "Analytics and reports" "Usage indicators and exports" "Module"
            }

            workers = container "Background workers" "Audio processing, alignment, search indexing, notifications, report export, radio schedule. Run on a separate host" "Node.js, pg-boss (ADR-012)"

            db = container "Database" "Content model, users, plans, versions, job queue (own schema)" "PostgreSQL 16 (ADR-002, ADR-003)" "Database"
            searchengine = container "Search engine" "Arabic search index with custom analyzer chain" "OpenSearch (ADR-013)" "Database"
            cache = container "Cache" "Cache and rate limiting only. Never holds queue state" "Redis" "Database"
            storage = container "Audio storage" "Original and processed audio files, private origin" "S3-compatible object storage" "Database"
            monitoring = container "Infrastructure monitoring" "Resource, uptime and cost dashboards with alerts. Runs outside the application hosts (ADR-023)" "Grafana, Uptime Kuma" "Monitoring"
            errors = container "Error monitoring" "Collects errors and crash reports from the apps, web, API and workers. Self-hosted so error data stays in our infrastructure (ADR-023)" "GlitchTip (Sentry-compatible); Sentry is the alternative" "Monitoring"
            playout = container "Radio playout (optional)" "Live stream of the radio schedule if the First Party chooses Option B" "Liquidsoap, Icecast" "Optional"
        }

        # ---- External systems --------------------------------------------
        push = softwareSystem "Apple and Google push services" "Deliver notifications to devices" "External"
        mail = softwareSystem "Email service (to be chosen)" "Account and notification email" "External"

        # ---- Level 1 relationships ---------------------------------------
        learner -> noor "Reads, searches, listens" "iOS, Android, web"
        editor -> noor "Manages content and audio" "Admin dashboard"
        scholar -> noor "Reviews and approves" "Admin dashboard"
        noor -> push "Sends notifications" "HTTPS"
        noor -> mail "Sends email through" "HTTPS"
        radioListeners -> noor "Listen to the live stream (Option B)" "HTTPS, audio stream"

        # ---- Level 2 relationships ---------------------------------------
        learner -> mobile "Uses"
        learner -> web "Uses"
        editor -> admin "Uses"
        scholar -> admin "Uses"

        mobile -> edge "Calls the API" "HTTPS, JSON"
        web -> edge "Calls the API" "HTTPS, JSON"
        admin -> edge "Calls the API" "HTTPS, JSON"
        edge -> api "Forwards filtered traffic" "HTTPS"
        mobile -> mediaCdn "Streams and downloads audio" "HTTPS, byte ranges"
        web -> mediaCdn "Streams audio" "HTTPS, byte ranges"
        admin -> mediaCdn "Previews audio" "HTTPS, byte ranges"
        mediaCdn -> storage "Fetches audio on a cache miss" "HTTPS, private origin"
        radioListeners -> mediaCdn "Listen to the live stream" "HTTPS, audio stream"
        mediaCdn -> playout "Pulls the live stream" "HTTPS"

        api -> db "Reads and writes" "SQL (Prisma)"
        api -> searchengine "Queries" "HTTPS"
        api -> cache "Caches, rate limits" "Redis protocol"
        api -> storage "Creates upload and playback URLs" "S3 API"
        api -> errors "Sends errors" "HTTPS"

        workers -> db "Takes jobs, reads and writes" "SQL (pg-boss, Prisma)"
        workers -> searchengine "Indexes published content" "HTTPS"
        workers -> storage "Reads and writes audio" "S3 API"
        workers -> push "Sends notifications" "HTTPS"
        workers -> mail "Sends email" "HTTPS"
        workers -> errors "Sends errors" "HTTPS"
        mobile -> errors "Sends crash and error reports" "HTTPS"
        web -> errors "Sends error reports" "HTTPS"
        admin -> errors "Sends error reports" "HTTPS"
        monitoring -> api "Collects metrics, checks uptime" "HTTPS"
        monitoring -> workers "Collects metrics" "HTTPS"
        monitoring -> db "Collects metrics" "SQL"
        monitoring -> searchengine "Collects metrics" "HTTPS"

        playout -> api "Reads radio schedule" "HTTPS"
        playout -> storage "Reads published audio" "S3 API"

        # ---- Level 3 relationships (inside the API) ----------------------
        library -> content "Reads published content"
        library -> cache "Caches responses"
        approval -> content "Publishes versions"
        approval -> bus "Emits published event"
        bus -> searchmod "Notifies of published content"
        bus -> notifications "Notifies of published content"
        bus -> db "Enqueues jobs (pg-boss)"
        searchmod -> searchengine "Queries"
        searchmod -> content "Resolves hits to content"
        audiomod -> content "Links audio to hadith text"
        audiomod -> storage "Creates signed URLs"
        radiomod -> audiomod "Takes published audio"
        plans -> content "References hadith and audio"
        notifications -> plans "Reads reminders"
        analytics -> db "Reads usage data"
        content -> db "Reads and writes"
        approval -> db "Reads and writes"
        identity -> db "Reads and writes"
        plans -> db "Reads and writes"
        notifications -> db "Enqueues jobs"
        radiomod -> db "Reads and writes"
    }

    views {
        systemContext noor "L1-Context" "Who uses Noor and what it talks to" {
            include *
            autolayout lr
        }

        container noor "L2-Containers" "What runs inside the Noor platform" {
            include *
            autolayout lr
        }

        component api "L3-API-Modules" "Modules inside the API (ADR-010)" {
            include *
            autolayout tb
        }

        styles {
            element "Person" {
                shape Person
                background #08427b
                color #ffffff
            }
            element "Software System" {
                background #1168bd
                color #ffffff
            }
            element "Container" {
                background #438dd5
                color #ffffff
            }
            element "Component" {
                background #85bbf0
                color #000000
            }
            element "Database" {
                shape Cylinder
            }
            element "Client" {
                shape RoundedBox
            }
            element "Optional" {
                border Dashed
            }
            element "Edge" {
                shape Hexagon
            }
            element "Managed" {
                background #2e7d6b
                color #ffffff
                border Dashed
            }
            element "Monitoring" {
                background #6b5b95
                color #ffffff
            }
            element "External" {
                background #999999
                color #ffffff
            }
        }
    }
}
