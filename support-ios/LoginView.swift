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
                    
                    // Set user to standard initially (default state)
                    userState.updatePlan(.standard)
                    
                    // 🔐 Identify user with initial properties
                    PostHogSDK.shared.identify(
                        username,
                        userProperties: [
                            "login_method": "mock",
                            "role": "tester",
                            "plan": PlanType.standard.rawValue // Default to standard plan
                        ],
                        userPropertiesSetOnce: [
                            "date_of_first_log_in": ISO8601DateFormatter().string(from: Date())
                        ]
                    )
                    
                    // Log login event with plan property
                    PostHogSDK.shared.capture("user_logged_in", properties: [
                        "plan": PlanType.standard.rawValue
                    ])
                    
                    // Flush to ensure the identify call is sent immediately
                    PostHogSDK.shared.flush()
                    
                    // Complete login - feature flags are already loaded by identify
                    isLoggingIn = false
                    isLoggedIn = true
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


