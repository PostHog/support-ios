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
        
        // Register for the feature flags notification before SDK initialization
        NotificationCenter.default.addObserver(
            forName: PostHogSDK.didReceiveFeatureFlags,
            object: nil,
            queue: nil
        ) { _ in
            print("Feature flags received from PostHog!")
            
            // Example of checking a flag after they're loaded
            if PostHogSDK.shared.isFeatureEnabled("show-pro-features") {
                print("Pro features are enabled for this user")
            }
        }

        let config = PostHogConfig(apiKey: POSTHOG_API_KEY, host: POSTHOG_HOST)
        config.captureApplicationLifecycleEvents = true  // ✅ Recommended for live apps
        config.captureScreenViews = false                // 🚫 Disable if using SwiftUI
        config.captureElementInteractions = true
        config.sessionReplay = true
        config.sessionReplayConfig.screenshotMode = true  // ✅ Required for SwiftUI
        config.flushAt = 1  // Setting to 1 for test app to ensure immediate feature flag updates
        config.debug = true  // ✅ Development only
        
        // Enable feature flags
        config.preloadFeatureFlags = true  // Preload flags when SDK initializes

        PostHogSDK.shared.setup(config)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
