import SwiftUI
import PostHog

struct FeatureFlagsExampleView: View {
    @EnvironmentObject var userState: UserState
    @State private var isLoadingFeatureFlags = true
    @State private var showFeatureA = false
    @State private var showFeatureB = false
    @State private var textColor: Color = .primary
    @State private var buttonStyle: String = "Standard"
    
    // Define actual feature flag keys - these are the exact keys to use in PostHog
    private let featureAFlagKey = "ios-feature-a"
    private let featureBFlagKey = "ios-feature-b"
    private let textColorFlagKey = "ios-text-color"
    private let buttonStyleFlagKey = "ios-button-style"
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if isLoadingFeatureFlags {
                    ProgressView("Loading feature flags...")
                        .padding(.top, 50)
                } else {
                    // Live feature flags example
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Live Example")
                            .font(.headline)
                        
                        Text("This screen is reading real feature flags from PostHog. Your current plan (\(userState.plan.displayName)) determines what you see.")
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
                            title: "Premium Analytics",
                            description: "This feature is \(showFeatureA ? "enabled" : "disabled") for your plan",
                            isEnabled: showFeatureA,
                            flagName: featureAFlagKey
                        )
                        
                        featureFlagCard(
                            title: "Custom Dashboards",
                            description: "This feature is \(showFeatureB ? "enabled" : "disabled") for your plan",
                            isEnabled: showFeatureB,
                            flagName: featureBFlagKey
                        )
                        
                        // UI styling controlled by feature flags
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Dynamic UI Styling")
                                .font(.headline)
                            
                            Text("Text color and button style are controlled by feature flags")
                                .font(.subheadline)
                                .foregroundColor(textColor)
                            
                            Button("Reload Feature Flags") {
                                reloadFeatureFlags()
                            }
                            .padding()
                            .background(userState.plan.color)
                            .foregroundColor(.white)
                            .cornerRadius(buttonStyle == "rounded" ? 20 : 8)
                            .shadow(radius: buttonStyle == "shadowed" ? 5 : 0)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                        .padding(.horizontal)
                    }
                    
                    // Flag details
                    VStack(alignment: .leading, spacing: 12) {
                        Text("How These Feature Flags Work")
                            .font(.headline)
                        
                        Text("These feature flags use the following targeting rules:")
                            .font(.subheadline)
                        
                        flagDescription(
                            name: featureAFlagKey,
                            description: "Boolean flag enabled based on user plan (Pro and Enterprise)"
                        )
                        
                        flagDescription(
                            name: featureBFlagKey,
                            description: "Boolean flag enabled only for Enterprise plan users"
                        )
                        
                        flagDescription(
                            name: textColorFlagKey,
                            description: "String flag with possible values: 'blue', 'green', 'purple', 'default'"
                        )
                        
                        flagDescription(
                            name: buttonStyleFlagKey,
                            description: "String flag with possible values: 'standard', 'rounded', 'shadowed'"
                        )
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
            
            Text("Flag key: \(flagName)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
    
    private func flagDescription(name: String, description: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(name)
                .font(.system(.subheadline, design: .monospaced))
                .bold()
            
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 6)
    }
    
    private func loadFeatureFlags() {
        isLoadingFeatureFlags = true
        
        // Log the current user information
        print("Loading feature flags for user: \(userState.userId), plan: \(userState.plan.rawValue)")
        
        // POSTHOG: Read the feature flag values without unnecessary reloading
        // Now that flags are centrally managed, we just need to read the current values
        checkFeatureFlags()
    }
    
    private func checkFeatureFlags() {
        // POSTHOG: Boolean feature flag - checks if feature is enabled
        // isFeatureEnabled returns a boolean indicating if a flag is enabled for the current user
        self.showFeatureA = PostHogSDK.shared.isFeatureEnabled(self.featureAFlagKey)
        print("Feature A flag (\(self.featureAFlagKey)) enabled: \(self.showFeatureA)")
        
        // POSTHOG: Check if there's a payload for more information
        // Feature flags can include additional data beyond just on/off
        if let payload = PostHogSDK.shared.getFeatureFlagPayload(self.featureAFlagKey) {
            print("Feature A payload: \(payload)")
        }
        
        // POSTHOG: Second boolean feature flag example
        self.showFeatureB = PostHogSDK.shared.isFeatureEnabled(self.featureBFlagKey)
        print("Feature B flag (\(self.featureBFlagKey)) enabled: \(self.showFeatureB)")
        
        if let payload = PostHogSDK.shared.getFeatureFlagPayload(self.featureBFlagKey) {
            print("Feature B payload: \(payload)")
        }
        
        // POSTHOG: String-value feature flag - requires retrieving the value
        // getFeatureFlag returns the actual value of the flag, not just true/false
        if let textColorValue = PostHogSDK.shared.getFeatureFlag(self.textColorFlagKey) as? String {
            print("Text color flag value: \(textColorValue)")
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
            
            if let payload = PostHogSDK.shared.getFeatureFlagPayload(self.textColorFlagKey) {
                print("Text color payload: \(payload)")
            }
        } else {
            // POSTHOG: Providing fallbacks when feature flags aren't available
            // This ensures the app still works even if flags fail to load
            self.textColor = self.userState.plan.color
            print("Text color flag not found, using fallback based on plan color")
        }
        
        // POSTHOG: String-value feature flag for UI component styling
        if let buttonStyleValue = PostHogSDK.shared.getFeatureFlag(self.buttonStyleFlagKey) as? String {
            print("Button style flag value: \(buttonStyleValue)")
            self.buttonStyle = buttonStyleValue
            
            if let payload = PostHogSDK.shared.getFeatureFlagPayload(self.buttonStyleFlagKey) {
                print("Button style payload: \(payload)")
            }
        } else {
            // POSTHOG: Another fallback example based on user's plan tier
            switch self.userState.plan {
            case .enterprise:
                self.buttonStyle = "shadowed"
            case .pro:
                self.buttonStyle = "rounded"
            case .standard:
                self.buttonStyle = "standard"
            }
            print("Button style flag not found, using fallback based on plan: \(self.buttonStyle)")
        }
        
        // Print debugging information for individual flags
        print("--------- FEATURE FLAG STATUS ---------")
        print("Feature A (\(self.featureAFlagKey)): \(self.showFeatureA)")
        print("Feature B (\(self.featureBFlagKey)): \(self.showFeatureB)")
        print("Text Color (\(self.textColorFlagKey)): \(self.textColor)")
        print("Button Style (\(self.buttonStyleFlagKey)): \(self.buttonStyle)")
        print("--------------------------------------")
        
        // POSTHOG: Track feature flag evaluation for analytics
        // This helps understand which flags are being evaluated and their values
        PostHogSDK.shared.capture("feature_flags_evaluated", properties: [
            "feature_a_enabled": self.showFeatureA,
            "feature_b_enabled": self.showFeatureB, 
            "text_color_value": self.textColor.description,
            "button_style_value": self.buttonStyle,
            "current_plan": self.userState.plan.rawValue,
            "current_user": self.userState.userId
        ])
        
        // Update the loading state after everything is processed
        self.isLoadingFeatureFlags = false
    }
    
    private func reloadFeatureFlags() {
        // Animation to show flag reloading
        withAnimation {
            isLoadingFeatureFlags = true
        }
        
        // POSTHOG: This button demonstrates manual flag reloading
        // In a real app, this should only be needed for debugging or special cases
        FeatureFlagManager.reloadFeatureFlags {
            // After flags are reloaded, check their values
            self.checkFeatureFlags()
            
            // Track this special manual reload action
            PostHogSDK.shared.capture("feature_flags_manually_reloaded")
            PostHogSDK.shared.flush()
        }
    }
} 