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
                    
                    // 🔐 Identify user with initial properties (plan will be updated)
                    PostHogSDK.shared.identify(
                        username,
                        userProperties: [
                            "login_method": "mock",
                            "role": "tester"
                            // Plan will be determined by feature flag or set to standard
                        ],
                        userPropertiesSetOnce: [
                            "date_of_first_log_in": ISO8601DateFormatter().string(from: Date())
                        ]
                    )
                    
                    // Flush to ensure the identify call is sent immediately
                    PostHogSDK.shared.flush()
                    
                    // Reload feature flags to get the user's plan
                    PostHogSDK.shared.reloadFeatureFlags {
                        // Check for user plan feature flag
                        if let userPlan = PostHogSDK.shared.getFeatureFlag("user-plan") as? String,
                           let planType = PlanType(rawValue: userPlan) {
                            // Set user plan based on feature flag
                            userState.updatePlan(planType)
                            
                            // Update the plan in PostHog properties
                            PostHogSDK.shared.identify(
                                username,
                                userProperties: [
                                    "plan": planType.rawValue
                                ]
                            )
                            
                            print("User plan set from feature flag: \(planType.displayName)")
                        } else {
                            // Default to standard plan if no feature flag exists
                            userState.updatePlan(.standard)
                            
                            // Update the plan in PostHog properties
                            PostHogSDK.shared.identify(
                                username,
                                userProperties: [
                                    "plan": PlanType.standard.rawValue
                                ]
                            )
                            
                            print("No user plan feature flag found, using standard plan")
                        }
                        
                        // Complete login
                        isLoggingIn = false
                        isLoggedIn = true
                    }
                }
            }
            .disabled(isLoggingIn)
            
            if isLoggingIn {
                ProgressView("Loading your plan...")
                    .padding(.top)
            }
        }
        .padding()
    }
}


