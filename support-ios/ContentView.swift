//
//  ContentView.swift
//  support-ios
//
//  Created by Joshua Ordehi on 23/4/25.
//

import SwiftUI
import PostHog

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            TypingView()
                .tabItem { Label("Typing", systemImage: "keyboard") }
                .tag(0)

            TappingView()
                .tabItem { Label("Tapping", systemImage: "hand.tap") }
                .tag(1)

            ScrollingView()
                .tabItem { Label("Scrolling", systemImage: "scroll") }
                .tag(2)
        }
        .onChange(of: selectedTab) { newTab in
            let tabName = ["Typing", "Tapping", "Scrolling"][newTab]
            PostHogSDK.shared.capture("Tab Switched", properties: [
                "tab": tabName,
                "tab_index": newTab
            ])
        }
    }
}
