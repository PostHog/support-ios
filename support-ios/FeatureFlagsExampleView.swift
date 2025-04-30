import SwiftUI
import PostHog

struct FeatureFlagsExampleView: View {
    @EnvironmentObject var userState: UserState
    @State private var isLoadingFeatureFlags = true
    @State private var showFeatureA = false
    @State private var showFeatureB = false
    @State private var textColor: Color = .primary
    @State private var buttonStyle: String = "Standard"
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if isLoadingFeatureFlags {
                    ProgressView("Loading feature flags...")
                        .padding(.top, 50)
                } else {
                    // Educational section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Feature Flags")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Feature flags let you control which users see which features. They're perfect for gradual rollouts, A/B testing, and plan-based features.")
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        Divider()
                            .padding(.vertical, 8)
                        
                        Text("Live Example")
                            .font(.headline)
                        
                        Text("This screen is reading real feature flags. Your current plan (\(userState.plan.displayName)) determines what you see.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)
                    
                    // Feature flag controlled components
                    VStack(spacing: 24) {
                        // UI controlled by feature flags
                        featureFlagCard(
                            title: "Feature A",
                            description: "This feature is \(showFeatureA ? "enabled" : "disabled") for your plan",
                            isEnabled: showFeatureA,
                            flagName: "feature-a"
                        )
                        
                        featureFlagCard(
                            title: "Feature B",
                            description: "This feature is \(showFeatureB ? "enabled" : "disabled") for your plan",
                            isEnabled: showFeatureB,
                            flagName: "feature-b"
                        )
                        
                        // UI styling controlled by feature flags
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Dynamic UI Styling")
                                .font(.headline)
                            
                            Text("Text color and button style are controlled by feature flags")
                                .font(.subheadline)
                                .foregroundColor(textColor)
                            
                            Button("Button Style: \(buttonStyle)") {
                                reloadFeatureFlags()
                            }
                            .padding()
                            .background(userState.plan.color)
                            .foregroundColor(.white)
                            .cornerRadius(buttonStyle == "Rounded" ? 20 : 8)
                            .shadow(radius: buttonStyle == "Shadowed" ? 5 : 0)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                        .padding(.horizontal)
                    }
                    
                    // Code example
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Swift Implementation")
                            .font(.headline)
                        
                        Text("Here's how to implement feature flags in Swift:")
                            .font(.subheadline)
                        
                        codeExample
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
        .onAppear {
            loadFeatureFlags()
        }
    }
    
    private func featureFlagCard(title: String, description: String, isEnabled: Bool, flagName: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.headline)
                
                Spacer()
                
                Text(isEnabled ? "Enabled" : "Disabled")
                    .font(.subheadline)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(isEnabled ? Color.green.opacity(0.2) : Color.gray.opacity(0.2))
                    .foregroundColor(isEnabled ? .green : .gray)
                    .cornerRadius(4)
            }
            
            Text(description)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Divider()
            
            Text("Flag name: \(flagName)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
    
    private var codeExample: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("// Check a boolean feature flag")
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.secondary)
            
            Text("if let isEnabled = PostHogSDK.shared.getFeatureFlag(\"feature-a\") as? Bool, isEnabled {")
                .font(.system(.caption, design: .monospaced))
            
            Text("    // The feature is enabled for this user")
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.secondary)
                .padding(.leading, 16)
            
            Text("}")
                .font(.system(.caption, design: .monospaced))
            
            Text("")
                .font(.system(.caption, design: .monospaced))
            
            Text("// Check a string feature flag")
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.secondary)
            
            Text("if let variant = PostHogSDK.shared.getFeatureFlag(\"plan-features\") as? String {")
                .font(.system(.caption, design: .monospaced))
            
            Text("    switch variant {")
                .font(.system(.caption, design: .monospaced))
                .padding(.leading, 16)
            
            Text("    case \"pro\", \"enterprise\":")
                .font(.system(.caption, design: .monospaced))
                .padding(.leading, 32)
            
            Text("        // Enable premium features")
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.secondary)
                .padding(.leading, 48)
            
            Text("    default:")
                .font(.system(.caption, design: .monospaced))
                .padding(.leading, 32)
            
            Text("        // Standard features only")
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.secondary)
                .padding(.leading, 48)
            
            Text("    }")
                .font(.system(.caption, design: .monospaced))
                .padding(.leading, 16)
            
            Text("}")
                .font(.system(.caption, design: .monospaced))
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    
    private func loadFeatureFlags() {
        isLoadingFeatureFlags = true
        
        // Explicitly reload feature flags to ensure we have the latest values
        PostHogSDK.shared.reloadFeatureFlags()
        
        // Add a slight delay to ensure flags are loaded
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Feature A flag
            if let featureA = PostHogSDK.shared.getFeatureFlag("feature-a") as? Bool {
                self.showFeatureA = featureA
            } else {
                // Fallback based on plan
                self.showFeatureA = userState.plan != .standard
            }
            
            // Feature B flag
            if let featureB = PostHogSDK.shared.getFeatureFlag("feature-b") as? Bool {
                self.showFeatureB = featureB
            } else {
                // Fallback based on plan
                self.showFeatureB = userState.plan == .enterprise
            }
            
            // Text color flag
            if let textColorValue = PostHogSDK.shared.getFeatureFlag("text-color") as? String {
                switch textColorValue {
                case "blue":
                    self.textColor = .blue
                case "green":
                    self.textColor = .green
                case "purple":
                    self.textColor = .purple
                default:
                    self.textColor = .primary
                }
            } else {
                // Fallback based on plan
                self.textColor = userState.plan.color
            }
            
            // Button style flag
            if let buttonStyleValue = PostHogSDK.shared.getFeatureFlag("button-style") as? String {
                self.buttonStyle = buttonStyleValue
            } else {
                // Fallback based on plan
                switch userState.plan {
                case .enterprise:
                    self.buttonStyle = "Shadowed"
                case .pro:
                    self.buttonStyle = "Rounded"
                case .standard:
                    self.buttonStyle = "Standard"
                }
            }
            
            // Update the loading state after everything is processed
            self.isLoadingFeatureFlags = false
        }
    }
    
    private func reloadFeatureFlags() {
        // Animation to show flag reloading
        withAnimation {
            isLoadingFeatureFlags = true
        }
        
        // Reload the flags
        loadFeatureFlags()
        
        // Capture the event
        PostHogSDK.shared.capture("feature_flags_reloaded")
    }
} 