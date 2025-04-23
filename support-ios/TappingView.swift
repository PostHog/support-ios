//
//  TappingView.swift
//  support-ios
//
//  Created by Joshua Ordehi on 23/4/25.
//


import SwiftUI
import PostHog

struct TappingView: View {
    @State private var count = 0

    var body: some View {
        VStack(spacing: 20) {
            Text("Tapping Test").font(.title)

            Button("Tap me!") {
                count += 1

                // 🔥 Custom PostHog event
                PostHogSDK.shared.capture("Button Tapped", properties: [
                    "count": count
                ])
            }

            Text("Tapped \(count) times")
        }
        .padding()
    }
}
