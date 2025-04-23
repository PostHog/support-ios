//
//  TappingView.swift
//  support-ios
//
//  Created by Joshua Ordehi on 23/4/25.
//


import SwiftUI
import PostHog

struct TappingView: View {
    @State private var count = 0
    @State private var planThemeColor = Color.blue
    @State private var planName = "Standard"
    @State private var buttonSize: CGFloat = 50
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Tapping Test")
                .font(.title)
                .foregroundColor(planThemeColor)
            
            Text("[\(planName) Plan Experience]")
                .font(.subheadline)
                .foregroundColor(planThemeColor)
                .padding(.bottom, 10)
            
            // Different button styles based on plan
            Button(action: {
                count += 1
                
                // 🔥 Custom PostHog event
                PostHogSDK.shared.capture("Button Tapped", properties: [
                    "count": count,
                    "plan": planName
                ])
            }) {
                ZStack {
                    Circle()
                        .fill(planThemeColor)
                        .frame(width: buttonSize, height: buttonSize)
                        .shadow(color: planThemeColor.opacity(0.5), radius: 10, x: 0, y: 5)
                    
                    Image(systemName: "hand.tap.fill")
                        .font(.system(size: buttonSize * 0.4))
                        .foregroundColor(.white)
                }
            }
            .padding()
            
            Text("Tapped \(count) times")
                .font(.title2)
                .fontWeight(.medium)
            
            // Pro plan feature - tap history
            if planName != "Standard" {
                VStack(alignment: .leading) {
                    Text("Tap Statistics:")
                        .font(.headline)
                        .foregroundColor(planThemeColor)
                    
                    Text("Average taps per minute: \(Int.random(in: 10...30))")
                    Text("Tap force: \(Int.random(in: 70...95))%")
                }
                .padding()
                .background(planThemeColor.opacity(0.1))
                .cornerRadius(8)
            }
            
            // Enterprise feature - unlock special animations
            if planName == "Enterprise" {
                Button("Trigger Special Animation") {
                    // This would trigger an animation in a real app
                    PostHogSDK.shared.capture("special_animation_triggered")
                }
                .padding()
                .background(planThemeColor)
                .foregroundColor(.white)
                .cornerRadius(8)
                .padding(.top, 10)
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
        // Check for plan feature flag
        if let userPlan = PostHogSDK.shared.getFeatureFlag("user-plan") as? String {
            switch userPlan {
            case "pro":
                planThemeColor = .purple
                planName = "Pro"
                buttonSize = 70 // Bigger button for Pro
            case "enterprise":
                planThemeColor = .green
                planName = "Enterprise"
                buttonSize = 90 // Even bigger for Enterprise
            default:
                planThemeColor = .blue
                planName = "Standard"
                buttonSize = 50 // Standard size
            }
        }
    }
}
