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
    @State private var selectedTab = 0
    @State private var showLoginForm = false
    @State private var eventName = ""

    var body: some View {
        if isLoggedIn {
            // ✅ Logged-in experience: TabView + Logout
            VStack {
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
                .onChange(of: selectedTab) {
                    let tabName = ["Typing", "Tapping", "Scrolling"][selectedTab]
                    PostHogSDK.shared.capture("Tab Switched", properties: [
                        "tab": tabName,
                        "tab_index": selectedTab
                    ])
                }

                Button("Logout") {
                    PostHogSDK.shared.reset()
                    isLoggedIn = false
                }
                .padding()
                .foregroundColor(.red)
            }
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


