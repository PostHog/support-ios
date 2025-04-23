//
//  TypingView.swift
//  support-ios
//
//  Created by Joshua Ordehi on 23/4/25.
//

import SwiftUI
import PostHog

struct TypingView: View {
    @State private var input = ""
    @State private var planThemeColor = Color.blue
    @State private var planName = "Standard"
    @State private var isLoading = true
    
    var body: some View {
        ZStack {
            if isLoading {
                ProgressView("Loading features...")
            } else {
                VStack(spacing: 20) {
                    Text("Typing Test")
                        .font(.title)
                        .foregroundColor(planThemeColor)
                    
                    Text("[\(planName) Plan Features]")
                        .font(.subheadline)
                        .foregroundColor(planThemeColor)
                        .padding(.bottom, 10)

                    TextField("Type something...", text: $input)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(planThemeColor, lineWidth: 2)
                                .padding(4)
                        )

                    Text("You typed: \(input)")
                        .fontWeight(.medium)
                    
                    // Pro and above feature
                    if planName != "Standard" {
                        Text("Character count: \(input.count)")
                            .font(.caption)
                            .padding(.top, 5)
                    }
                    
                    // Enterprise only feature
                    if planName == "Enterprise" {
                        Text("Word count: \(input.split(separator: " ").count)")
                            .font(.caption)
                            .padding(.top, 5)
                    }
                }
                .padding()
                .background(planThemeColor.opacity(0.05))
                .cornerRadius(12)
                .padding()
            }
        }
        .onAppear {
            isLoading = true
            DispatchQueue.main.async {
                checkPlanFeatureFlag()
            }
        }
    }
    
    private func checkPlanFeatureFlag() {
        print("Checking plan feature flag in TypingView")
        
        // Reload feature flags to ensure we have the latest values
        PostHogSDK.shared.reloadFeatureFlags()
        
        // Add a small delay to ensure the flags are loaded
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Check the feature flag that targets based on plan property
            if let planFeatures = PostHogSDK.shared.getFeatureFlag("plan-features") as? String {
                switch planFeatures {
                case "pro":
                    planThemeColor = .purple
                    planName = "Pro"
                case "enterprise":
                    planThemeColor = .green
                    planName = "Enterprise"
                default:
                    planThemeColor = .blue
                    planName = "Standard"
                }
                
                print("Plan features from feature flag in TypingView: \(planFeatures)")
            } else {
                // Default to standard plan if no feature flag is found
                planThemeColor = .blue
                planName = "Standard"
                print("No plan-features flag found in TypingView, using Standard")
            }
            
            // Update loading state after everything is processed
            isLoading = false
        }
    }
}
