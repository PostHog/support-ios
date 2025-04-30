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
                    
                    // POSTHOG: Reload feature flags centrally after login
                    // This is one of the two critical times flags need to be refreshed
                    FeatureFlagManager.reloadFeatureFlags {
                        // Complete login after flags are loaded
                        isLoggingIn = false
                        isLoggedIn = true
                        
                        // The DashboardView will now have the latest flag values based on the user's plan
                    }
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


