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
        let POSTHOG_API_KEY = "YOUR_POSTHOG_API_KEY_HERE"
        let POSTHOG_HOST = "https://us.i.posthog.com"
        
        // POSTHOG: Register for feature flag updates before SDK initialization
        // This observer will be triggered whenever feature flags are updated from the server
        // It's important to set this up before initializing PostHog
        NotificationCenter.default.addObserver(
            forName: PostHogSDK.didReceiveFeatureFlags,
            object: nil,
            queue: nil
        ) { _ in
            print("Feature flags received from PostHog!")
            
            // POSTHOG: Example of checking a specific feature flag value after receiving updates
            // Here we check for the "plan-features" flag which controls the user's plan level
            if let planFeatures = PostHogSDK.shared.getFeatureFlag("plan-features") as? String {
                print("Plan features flag value: \(planFeatures)")
            } else {
                print("Plan features flag not found or not enabled")
            }
        }

        // POSTHOG: Configure the SDK with various tracking options
        let config = PostHogConfig(apiKey: POSTHOG_API_KEY, host: POSTHOG_HOST)
        
        // POSTHOG: Track app lifecycle events (app open, app background, etc.)
        // This is recommended for production apps to understand user engagement
        config.captureApplicationLifecycleEvents = true
        
        // POSTHOG: Disable automatic screen view tracking since we're using SwiftUI
        // For SwiftUI, it's better to manually track screen views using custom events
        config.captureScreenViews = false
        
        // POSTHOG: Enable element interaction tracking (button taps, etc.)
        // This powers the autocapture functionality
        config.captureElementInteractions = true
        
        // POSTHOG: Enable session replay to record user interactions
        config.sessionReplay = true
        
        // POSTHOG: Use screenshot mode for SwiftUI apps
        // This is required for proper session replay in SwiftUI
        config.sessionReplayConfig.screenshotMode = true
        
        // POSTHOG: Set flush threshold to 1 for testing purposes
        // In production, you'd use a higher value (default is 20) to batch events
        config.flushAt = 1
        
        // POSTHOG: Enable debug mode for development
        // Remove this in production to avoid console logs
        config.debug = true
        
        // POSTHOG: Enable preloading of feature flags on SDK initialization
        // This ensures flags are available as soon as possible
        config.preloadFeatureFlags = true

        // POSTHOG: Initialize the SDK with our configuration
        PostHogSDK.shared.setup(config)
    }

    var body: some Scene {
        WindowGroup {
            MainView()
                .preferredColorScheme(.light) // Use light mode by default for demo
        }
    }
}

/// Main container view that handles app flow
struct MainView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    
    var body: some View {
        if !hasCompletedOnboarding {
            OnboardingView()
        } else {
            ContentView()
        }
    }
}
