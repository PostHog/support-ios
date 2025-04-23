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
    @State private var username = ""
    @State private var password = ""

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
                    // 🔐 Identify user with full user properties
                    PostHogSDK.shared.identify(
                        username,
                        userProperties: [
                            "login_method": "mock",
                            "role": "tester"
                        ],
                        userPropertiesSetOnce: [
                            "date_of_first_log_in": ISO8601DateFormatter().string(from: Date())
                        ]
                    )

                    isLoggedIn = true
                }
            }
        }
        .padding()
    }
}


