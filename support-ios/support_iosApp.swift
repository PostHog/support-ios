//
//  support_iosApp.swift
//  support-ios
//
//  Created by Joshua Ordehi on 23/4/25.
//

import SwiftUI
import PostHog

@main
struct support_iosApp: App {
    init() {
        let POSTHOG_API_KEY = "***REMOVED***"
        let POSTHOG_HOST = "https://us.i.posthog.com"

        let config = PostHogConfig(apiKey: POSTHOG_API_KEY, host: POSTHOG_HOST)
        config.captureApplicationLifecycleEvents = true  // ✅ Recommended for live apps
        config.captureScreenViews = false                // 🚫 Disable if using SwiftUI
        config.captureElementInteractions = true
        config.sessionReplay = true
        config.sessionReplayConfig.screenshotMode = true  // ✅ Required for SwiftUI
        config.flushAt = 10
        config.debug = true  // ✅ Development only

        PostHogSDK.shared.setup(config)

    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
