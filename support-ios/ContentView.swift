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
    @State private var showFeatureExplorer = false

    var body: some View {
        if isLoggedIn {
            // ✅ Logged-in experience: TabView with main navigation
            TabView(selection: $selectedTab) {
                // Home/Dashboard tab
                NavigationView {
                    VStack {
                        Text("Welcome to PostHog iOS Showcase")
                            .font(AppDesign.Typography.titleText)
                            .foregroundColor(AppDesign.Colors.text)
                            .padding()
                        
                        // Profile card
                        HStack {
                            VStack(alignment: .leading, spacing: AppDesign.Spacing.small) {
                                Text("User: \(userState.userId)")
                                    .font(AppDesign.Typography.headline)
                                    .foregroundColor(AppDesign.Colors.text)
                                
                                Text("Plan: \(userState.plan.displayName)")
                                    .font(AppDesign.Typography.bodyText)
                                    .foregroundColor(AppDesign.Colors.textSecondary)
                                
                                Button("Logout") {
                                    logout()
                                }
                                .foregroundColor(AppDesign.Colors.error)
                                .padding(.top, AppDesign.Spacing.small)
                            }
                            
                            Spacer()
                            
                            Circle()
                                .fill(userState.plan.color)
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Text(String(userState.userId.prefix(1)).uppercased())
                                        .font(.system(size: 22, weight: .bold))
                                        .foregroundColor(.white)
                                )
                        }
                        .padding()
                        .background(AppDesign.Colors.card)
                        .cornerRadius(AppDesign.Radius.large)
                        .shadow(color: AppDesign.Shadows.small, radius: AppDesign.Shadows.smallRadius, x: 0, y: 1)
                        .padding()
                        
                        // Feature quick links
                        Button(action: {
                            showFeatureExplorer = true
                        }) {
                            HStack {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 24))
                                    .foregroundColor(AppDesign.Colors.primaryOrange)
                                
                                Text("Explore All Features")
                                    .font(AppDesign.Typography.bodyText)
                                    .foregroundColor(AppDesign.Colors.text)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(AppDesign.Colors.textSecondary)
                            }
                            .padding()
                            .background(AppDesign.Colors.card)
                            .cornerRadius(AppDesign.Radius.large)
                            .shadow(color: AppDesign.Shadows.small, radius: AppDesign.Shadows.smallRadius, x: 0, y: 1)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal)
                        
                        Spacer()
                    }
                    .background(AppDesign.Colors.background)
                    .navigationTitle("Home")
                    .navigationBarTitleDisplayMode(.inline)
                    .sheet(isPresented: $showFeatureExplorer) {
                        FeatureShowcaseView()
                            .environmentObject(userState)
                    }
                }
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(0)
                
                // Features tab
                FeatureShowcaseView()
                    .environmentObject(userState)
                    .tabItem {
                        Label("Features", systemImage: "sparkles")
                    }
                    .tag(1)
                
                // Dashboard tab (existing)
                DashboardView()
                    .environmentObject(userState)
                    .tabItem {
                        Label("Dashboard", systemImage: "chart.bar")
                    }
                    .tag(2)
                
                // Settings tab
                SettingsView()
                    .environmentObject(userState)
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
                    .tag(6)
                
                // Demo views for testing
                Group {
                    TypingView()
                        .tabItem {
                            Label("Typing", systemImage: "keyboard")
                        }
                        .tag(3)
                    
                    TappingView()
                        .tabItem {
                            Label("Tapping", systemImage: "hand.tap")
                        }
                        .tag(4)
                    
                    ScrollingView()
                        .tabItem {
                            Label("Scrolling", systemImage: "scroll")
                        }
                        .tag(5)
                }
            }
            .onChange(of: selectedTab) {
                trackTabChange()
            }
            .accentColor(AppDesign.Colors.primaryOrange)
            .environmentObject(userState)
            .onAppear {
                setupDashboardNavigation()
            }
        } else {
            // ✅ Logged-out experience: Login screen
            ZStack {
                AppDesign.Colors.background
                    .ignoresSafeArea()
                
                VStack(spacing: AppDesign.Spacing.large) {
                    // Logo and title
                    VStack(spacing: AppDesign.Spacing.medium) {
                        Image(systemName: "swift")
                            .font(.system(size: 48))
                            .foregroundColor(AppDesign.Colors.primaryOrange)
                            .padding()
                            .background(
                                Circle()
                                    .fill(AppDesign.Colors.primaryOrange.opacity(0.1))
                            )
                        
                        Text("PostHog iOS Showcase")
                            .font(AppDesign.Typography.titleText)
                            .foregroundColor(AppDesign.Colors.text)
                        
                        Text("Please login to continue")
                            .font(AppDesign.Typography.bodyText)
                            .foregroundColor(AppDesign.Colors.textSecondary)
                    }
                    .padding(.top, AppDesign.Spacing.huge)
                    
                    // Login form
                    if showLoginForm {
                        LoginView()
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                            .environmentObject(userState)
                            .padding()
                            .background(AppDesign.Colors.card)
                            .cornerRadius(AppDesign.Radius.large)
                            .shadow(color: AppDesign.Shadows.medium, radius: AppDesign.Shadows.mediumRadius, x: 0, y: 2)
                            .padding()
                    }
                    
                    // Login button
                    Button(action: {
                        withAnimation {
                            showLoginForm.toggle()
                        }
                        // POSTHOG: Track login button clicks with a custom event
                        // This helps analyze how many users attempt to log in
                        PostHogSDK.shared.capture("login_button_clicked")
                    }) {
                        HStack {
                            Image(systemName: showLoginForm ? "xmark" : "person.fill")
                            Text(showLoginForm ? "Cancel" : "Login")
                        }
                        .padding(.horizontal, AppDesign.Spacing.large)
                        .padding(.vertical, AppDesign.Spacing.medium)
                        .frame(maxWidth: 200)
                    }
                    .primaryButton()
                    
                    Spacer()
                    
                    // Test event section
                    VStack(spacing: AppDesign.Spacing.medium) {
                        Text("Test Event Capture")
                            .font(AppDesign.Typography.headline)
                            .foregroundColor(AppDesign.Colors.text)
                        
                        TextField("Event name", text: $eventName)
                            .padding()
                            .background(AppDesign.Colors.card)
                            .cornerRadius(AppDesign.Radius.medium)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppDesign.Radius.medium)
                                    .stroke(AppDesign.Colors.border, lineWidth: 1)
                            )
                        
                        Button(action: {
                            sendTestEvent()
                        }) {
                            Text("Send Event")
                                .padding(.horizontal, AppDesign.Spacing.large)
                                .padding(.vertical, AppDesign.Spacing.medium)
                                .frame(maxWidth: 200)
                        }
                        .secondaryButton()
                    }
                    .padding()
                    .background(AppDesign.Colors.card)
                    .cornerRadius(AppDesign.Radius.large)
                    .shadow(color: AppDesign.Shadows.small, radius: AppDesign.Shadows.smallRadius, x: 0, y: 1)
                    .padding()
                }
                .padding()
            }
        }
    }
    
    private func trackTabChange() {
        let tabNames = ["Home", "Features", "Dashboard", "Typing", "Tapping", "Scrolling"]
        if selectedTab < tabNames.count {
            // POSTHOG: Track tab navigation with tab name and index
            // This helps understand which sections of the app are most frequently used
            PostHogSDK.shared.capture("tab_switched", properties: [
                "tab": tabNames[selectedTab],
                "tab_index": selectedTab
            ])
        }
    }
    
    private func logout() {
        // POSTHOG: Reset user identification when logging out
        // This clears the current user's identity and starts a new anonymous session
        PostHogSDK.shared.reset()
        
        // Reset user state to standard plan
        userState.updatePlan(.standard)
        
        // POSTHOG: Log the logout event before user state changes
        // The flush ensures the event is sent immediately before app state changes
        PostHogSDK.shared.capture("user_logged_out")
        PostHogSDK.shared.flush()
        
        // Update login state
        isLoggedIn = false
    }
    
    private func sendTestEvent() {
        let name = eventName.isEmpty ? "generic_test_event" : eventName
        // POSTHOG: Send custom event with user-defined name
        // This demonstrates the flexibility of custom event tracking
        PostHogSDK.shared.capture(name)
        
        // Show feedback
        eventName = ""
    }
    
    private func setupDashboardNavigation() {
        // Listen for dashboard navigation notifications
        NotificationCenter.default.addObserver(
            forName: .navigateToDashboard,
            object: nil,
            queue: .main
        ) { _ in
            // First navigate to dashboard tab
            selectedTab = 2 // Dashboard tab index
            
            // POSTHOG: Track navigation to dashboard with source context
            // This helps understand navigation patterns and feature usage
            PostHogSDK.shared.capture("navigated_to_dashboard", properties: [
                "source": "upgrade_flow",
                "plan": userState.plan.rawValue
            ])
        }
    }
}


