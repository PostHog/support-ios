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
        config.captureApplicationLifecycleEvents = true
        config.sessionReplay = true
        config.captureScreenViews = true
        // capture application lifecycle events (installed, updated, opened, backgrounded)
        config.captureApplicationLifecycleEvents = true
        // capture element interactions (button presses, text input changes, etc.)
        config.captureElementInteractions = true
        config.flushAt = 1
        config.debug = true

        PostHogSDK.shared.setup(config)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
