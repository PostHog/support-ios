//
//  LoginView.swift
//  support-ios
//
//  Created by Joshua Ordehi on 23/4/25.
//

import SwiftUI
import PostHog

struct LoginView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @EnvironmentObject var userState: UserState
    @State private var username = ""
    @State private var password = ""
    @State private var isLoggingIn = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Mock Login").font(.title)

            TextField("Username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocorrectionDisabled(true)
                .autocapitalization(.none)

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Button("Login") {
                if !username.isEmpty {
                    isLoggingIn = true
                    
                    // Update user ID in our state
                    userState.updateUserId(username)
                    
                    // 🔐 Identify user without setting plan - we'll get this from PostHog
                    PostHogSDK.shared.identify(
                        username,
                        userProperties: [
                            "login_method": "mock",
                            "role": "tester"
                            // Don't set plan here - we'll get it from PostHog's stored properties
                        ]
                    )
                    
                    // Log login event
                    PostHogSDK.shared.capture("user_logged_in")
                    
                    // Flush to ensure the identify call is sent immediately
                    PostHogSDK.shared.flush()
                    
                    // Explicitly reload feature flags after login
                    // This will get the user's stored properties including their plan
                    PostHogSDK.shared.reloadFeatureFlags()
                    
                    // Complete login
                    isLoggingIn = false
                    isLoggedIn = true
                    
                    // The DashboardView will look at the feature flag values
                    // and update the UI based on the user's actual plan
                }
            }
            .disabled(isLoggingIn)
            
            if isLoggingIn {
                ProgressView("Logging in...")
                    .padding(.top)
            }
        }
        .padding()
    }
}


