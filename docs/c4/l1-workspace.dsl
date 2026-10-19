workspace "Noor in the Prophetic Sunnah" "Architecture model (level 1 sample)" {

    model {
        learner = person "Beneficiary" "Reads, searches and listens to hadith; follows plans; listens to Radio Noor"
        editor = person "Content team" "Enters and edits content, uploads and syncs audio, submits for review"
        scholar = person "Scholars and approvers" "Review and approve content in the approval cycle"

        noor = softwareSystem "Noor platform" "Mobile apps, web, admin dashboard, API, search, audio, radio, notifications"

        push = softwareSystem "Apple and Google push services" "Deliver notifications to devices" "External"
        monitor = softwareSystem "Monitoring and analytics" "Error monitoring, uptime, usage analytics" "External"

        learner -> noor "Reads, searches, listens" "iOS, Android, web"
        editor -> noor "Manages content and audio" "Admin dashboard"
        scholar -> noor "Reviews and approves" "Admin dashboard"
        noor -> push "Sends notifications" "HTTPS"
        noor -> monitor "Sends errors, metrics and events" "HTTPS"
    }

    views {
        systemContext noor "L1-Context" {
            include *
            autolayout lr
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
            element "External" {
                background #999999
                color #ffffff
            }
        }
    }
}
