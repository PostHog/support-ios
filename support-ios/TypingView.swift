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
    
    var body: some View {
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
        .onAppear {
            checkUserPlan()
        }
    }
    
    private func checkUserPlan() {
        // Check for plan feature flag first
        if let userPlan = PostHogSDK.shared.getFeatureFlag("user-plan") as? String {
            switch userPlan {
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
        }
    }
}
