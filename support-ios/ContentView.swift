//
//  ContentView.swift
//  support-ios
//
//  Created by Joshua Ordehi on 23/4/25.
//

import SwiftUI
import PostHog

struct ContentView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @StateObject private var userState = UserState()
    @State private var selectedTab = 0
    @State private var showLoginForm = false
    @State private var eventName = ""

    var body: some View {
        if isLoggedIn {
            // ✅ Logged-in experience: TabView with Dashboard + test views
            VStack {
                TabView(selection: $selectedTab) {
                    DashboardView()
                        .tabItem { Label("Dashboard", systemImage: "chart.bar") }
                        .tag(0)
                    
                    TypingView()
                        .tabItem { Label("Typing", systemImage: "keyboard") }
                        .tag(1)

                    TappingView()
                        .tabItem { Label("Tapping", systemImage: "hand.tap") }
                        .tag(2)

                    ScrollingView()
                        .tabItem { Label("Scrolling", systemImage: "scroll") }
                        .tag(3)
                }
                .onChange(of: selectedTab) {
                    let tabName = ["Dashboard", "Typing", "Tapping", "Scrolling"][selectedTab]
                    PostHogSDK.shared.capture("Tab Switched", properties: [
                        "tab": tabName,
                        "tab_index": selectedTab
                    ])
                }

                Button("Logout") {
                    // Reset PostHog user identification
                    PostHogSDK.shared.reset()
                    
                    // Reset user state to standard plan
                    userState.updatePlan(.standard)
                    
                    // Log the logout event
                    PostHogSDK.shared.capture("user_logged_out")
                    
                    // Update login state
                    isLoggedIn = false
                }
                .padding()
                .foregroundColor(.red)
            }
            .environmentObject(userState)
        } else {
            // ✅ Logged-out experience: Login button + event tester
            VStack(spacing: 20) {
                HStack {
                    Spacer()
                    Button("Login") {
                        showLoginForm.toggle()
                    }
                }

                if showLoginForm {
                    LoginView()
                        .padding(.vertical)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                        .environmentObject(userState)
                }

                Text("Logged Out Mode").font(.title)

                TextField("Type a name for the event...", text: $eventName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button("Send Event") {
                    let name = eventName.isEmpty ? "Generic Event" : eventName
                    PostHogSDK.shared.capture(name)
                    eventName = ""
                }
                .padding()
                .background(Color.blue.opacity(0.2))
                .cornerRadius(10)
            }
            .padding()
        }
    }
}


