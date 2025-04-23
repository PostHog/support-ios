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
        let config = PostHogConfig(apiKey: "phc_ddA554Xlja4bfLInShnZnM6b7d3Op1aQAaieWzw3oz7", host: "https://us.i.posthog.com")
        PostHogSDK.shared.setup(config)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

