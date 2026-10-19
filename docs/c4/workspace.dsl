workspace "Noor in the Prophetic Sunnah" "C4 model: levels 1 to 3. Source of truth for the architecture diagrams." {

    model {
        # ---- People -------------------------------------------------------
        learner = person "Beneficiary" "Reads, searches and listens to hadith; follows plans; listens to Radio Noor"
        editor = person "Content team" "Enters and edits content, uploads and syncs audio, submits for review"
        scholar = person "Scholars and approvers" "Review and approve content in the approval cycle"

        # ---- The system ---------------------------------------------------
        noor = softwareSystem "Noor platform" "Mobile apps, web, admin dashboard, API, search, audio, radio, notifications" {

            mobile = container "Mobile apps" "iOS and Android apps: library, search, audio with synced text, plans, radio" "React Native (proposed)" "Client"
            web = container "Public web app" "Responsive web platform for beneficiaries" "Next.js, React (proposed)" "Client"
            admin = container "Admin dashboard" "Arabic admin: content, audio sync, approval cycle, radio, reports" "React, TypeScript (ADR-011)" "Client"

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
            playout = container "Radio playout (optional)" "Live stream of the radio schedule if the First Party chooses Option B" "Liquidsoap, Icecast" "Optional"
        }

        # ---- External systems --------------------------------------------
        cdn = softwareSystem "CDN and WAF" "Edge delivery of audio and public endpoints, request filtering" "External"
        push = softwareSystem "Apple and Google push services" "Deliver notifications to devices" "External"
        mail = softwareSystem "Email service (to be chosen)" "Account and notification email" "External"
        monitor = softwareSystem "Monitoring and analytics" "Error monitoring, uptime, usage analytics" "External"

        # ---- Level 1 relationships ---------------------------------------
        learner -> noor "Reads, searches, listens" "iOS, Android, web"
        editor -> noor "Manages content and audio" "Admin dashboard"
        scholar -> noor "Reviews and approves" "Admin dashboard"
        noor -> push "Sends notifications" "HTTPS"
        noor -> mail "Sends email through" "HTTPS"
        noor -> monitor "Sends errors, metrics and events" "HTTPS"

        # ---- Level 2 relationships ---------------------------------------
        learner -> mobile "Uses"
        learner -> web "Uses"
        editor -> admin "Uses"
        scholar -> admin "Uses"

        mobile -> api "Calls" "HTTPS, JSON"
        web -> api "Calls" "HTTPS, JSON"
        admin -> api "Calls" "HTTPS, JSON"
        mobile -> cdn "Streams audio" "HTTPS, byte ranges"
        web -> cdn "Streams audio" "HTTPS, byte ranges"
        admin -> cdn "Previews audio" "HTTPS, byte ranges"
        cdn -> storage "Fetches audio" "HTTPS, private origin"
        cdn -> api "Forwards API traffic" "HTTPS"

        api -> db "Reads and writes" "SQL (Prisma)"
        api -> searchengine "Queries" "HTTPS"
        api -> cache "Caches, rate limits" "Redis protocol"
        api -> storage "Creates upload and playback URLs" "S3 API"
        api -> monitor "Sends errors" "HTTPS"

        workers -> db "Takes jobs, reads and writes" "SQL (pg-boss, Prisma)"
        workers -> searchengine "Indexes published content" "HTTPS"
        workers -> storage "Reads and writes audio" "S3 API"
        workers -> push "Sends notifications" "HTTPS"
        workers -> mail "Sends email" "HTTPS"
        workers -> monitor "Sends errors" "HTTPS"

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
            element "External" {
                background #999999
                color #ffffff
            }
        }
    }
}
