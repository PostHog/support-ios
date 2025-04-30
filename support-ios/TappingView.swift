//
//  TappingView.swift
//  support-ios
//
//  Created by Joshua Ordehi on 23/4/25.
//


import SwiftUI
import PostHog

struct EventTrackingView: View {
    @State private var count = 0
    @State private var planThemeColor = Color.blue
    @State private var planName = "Standard"
    @State private var buttonSize: CGFloat = 50
    @State private var isLoading = true
    @State private var showAnimation = false
    
    var body: some View {
        ZStack {
            if isLoading {
                ProgressView("Loading features...")
            } else {
                ScrollView {
                    VStack(spacing: 20) {
                        // Main tap button
                        VStack {
                            Text("Tapping Test")
                                .font(.headline)
                                .foregroundColor(planThemeColor)
                            
                            Text("[\(planName) Plan Experience]")
                                .font(.subheadline)
                                .foregroundColor(planThemeColor)
                                .padding(.bottom, 10)
                            
                            Button(action: {
                                count += 1
                                
                                // POSTHOG: Track button taps with custom properties
                                // This demonstrates capturing custom events with contextual data
                                // The properties contain the tap count and user's plan
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
                        }
                        .padding()
                        .background(planThemeColor.opacity(0.05))
                        .cornerRadius(12)
                        
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
                        
                        // Enterprise feature - special animations
                        if planName == "Enterprise" {
                            Button("Trigger Special Animation") {
                                showAnimation = true
                                // POSTHOG: Track premium feature usage
                                // This helps analyze which premium features are being used
                                PostHogSDK.shared.capture("special_animation_triggered")
                            }
                            .padding()
                            .background(planThemeColor)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .padding(.vertical, 10)
                        }
                        
                        // Add padding at the bottom to ensure content doesn't get hidden
                        Spacer().frame(height: 50)
                    }
                    .padding()
                }
                .overlay(
                    ZStack {
                        if showAnimation {
                            VStack {
                                Spacer()
                                
                                AnimationView()
                                    .frame(width: 200, height: 200)
                                    .transition(.scale)
                                
                                Spacer()
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.black.opacity(0.5))
                            .edgesIgnoringSafeArea(.all)
                            .onTapGesture {
                                withAnimation {
                                    showAnimation = false
                                }
                            }
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    withAnimation {
                                        showAnimation = false
                                    }
                                }
                            }
                        }
                    }
                )
            }
        }
        .onAppear {
            isLoading = true
            DispatchQueue.main.async {
                checkPlanFeatureFlag()
            }
        }
    }
    
    // A simple animation view
    struct AnimationView: View {
        @State private var animationAmount = 1.0
        
        var body: some View {
            ZStack {
                Circle()
                    .fill(Color.green)
                    .frame(width: 120, height: 120)
                    .scaleEffect(animationAmount)
                    .opacity(2 - animationAmount)
                    .animation(
                        .easeInOut(duration: 1)
                            .repeatForever(autoreverses: false),
                        value: animationAmount
                    )
                
                Image(systemName: "star.fill")
                    .resizable()
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(Double(animationAmount * 360)))
                    .animation(
                        .linear(duration: 1)
                            .repeatForever(autoreverses: false),
                        value: animationAmount
                    )
            }
            .onAppear {
                animationAmount = 2.0
            }
        }
    }
    
    private func checkPlanFeatureFlag() {
        print("Checking plan feature flag in EventTrackingView")
        
        // POSTHOG: Simply check feature flag value without reloading
        // Flag values are now centrally managed when user properties change
        if let planFeatures = PostHogSDK.shared.getFeatureFlag("plan-features") as? String {
            switch planFeatures {
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
            
            print("Plan features from feature flag in EventTrackingView: \(planFeatures)")
        } else {
            // Default to standard plan if no feature flag is found
            planThemeColor = .blue
            planName = "Standard"
            buttonSize = 50 // Standard size
            print("No plan-features flag found in EventTrackingView, using Standard")
        }
        
        // Update loading state after everything is processed
        isLoading = false
    }
}

// Keep TappingView for backward compatibility
struct TappingView: View {
    var body: some View {
        EventTrackingView()
    }
}
