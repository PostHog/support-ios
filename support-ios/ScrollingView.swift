//
//  ScrollingView.swift
//  support-ios
//
//  Created by Joshua Ordehi on 23/4/25.
//


import SwiftUI
import PostHog

struct ScrollingView: View {
    @State private var planThemeColor = Color.blue
    @State private var planName = "Standard"
    @State private var itemCount = 10 // Base number of items for Standard
    @State private var isLoading = true
    
    var body: some View {
        ZStack {
            if isLoading {
                ProgressView("Loading features...")
            } else {
                VStack {
                    VStack {
                        Text("Scrolling Test")
                            .font(.headline)
                            .foregroundColor(planThemeColor)
                        
                        Text("[\(planName) Plan - \(itemCount) Items]")
                            .font(.subheadline)
                            .foregroundColor(planThemeColor)
                            .padding(.bottom, 5)
                    }
                    .padding(.top)
                    
                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(1...itemCount, id: \.self) { i in
                                ItemRow(index: i, planThemeColor: planThemeColor, planName: planName)
                            }
                        }
                        .padding()
                    }
                }
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
        print("Checking plan feature flag in ScrollingView")
        
        // POSTHOG: Reload feature flags to ensure we have the latest values
        // Feature flags might have changed on the server since the app started
        PostHogSDK.shared.reloadFeatureFlags()
        
        // Add a small delay to ensure the flags are loaded
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // POSTHOG: Check the feature flag that determines user plan
            // This determines what content and features are available
            if let planFeatures = PostHogSDK.shared.getFeatureFlag("plan-features") as? String {
                switch planFeatures {
                case "pro":
                    planThemeColor = .purple
                    planName = "Pro"
                    itemCount = 25 // More items for Pro
                case "enterprise":
                    planThemeColor = .green
                    planName = "Enterprise"
                    itemCount = 50 // Even more for Enterprise
                default:
                    planThemeColor = .blue
                    planName = "Standard"
                    itemCount = 10 // Base amount
                }
                
                print("Plan features from feature flag in ScrollingView: \(planFeatures)")
            } else {
                // Default to standard plan if no feature flag is found
                planThemeColor = .blue
                planName = "Standard"
                itemCount = 10 // Base amount
                print("No plan-features flag found in ScrollingView, using Standard")
            }
            
            // POSTHOG: Track view shown event with plan and content information
            // This helps analyze different usage patterns by plan type
            PostHogSDK.shared.capture("scrolling_view_shown", properties: [
                "plan": planName,
                "item_count": itemCount
            ])
            
            // Update loading state after everything is processed
            isLoading = false
        }
    }
}

struct ItemRow: View {
    let index: Int
    let planThemeColor: Color
    let planName: String
    
    var body: some View {
        HStack {
            Text("Item \(index)")
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if planName != "Standard" {
                // Pro and Enterprise get badges
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(planThemeColor)
                    .padding(.trailing)
            }
            
            if planName == "Enterprise" {
                // Enterprise gets a star
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .padding(.trailing)
            }
        }
        .background(planThemeColor.opacity(0.1))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(planThemeColor.opacity(0.3), lineWidth: 1)
        )
    }
}
