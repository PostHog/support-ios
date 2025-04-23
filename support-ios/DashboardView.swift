import SwiftUI
import PostHog

struct DashboardView: View {
    @EnvironmentObject var userState: UserState
    @State private var showPlanPurchase = false
    @State private var isLoadingFeatureFlags = true
    
    // Feature flag states
    @State private var showProFeatures = false
    @State private var showEnterpriseFeatures = false
    @State private var customDashboardColor: Color = .blue
    
    var body: some View {
        NavigationView {
            ZStack {
                if isLoadingFeatureFlags {
                    ProgressView("Loading dashboard...")
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            currentPlanHeader
                            
                            // Standard features (available to all)
                            featuresSection("Standard Features", features: standardFeatures, color: .blue)
                            
                            // Pro features
                            if showProFeatures {
                                featuresSection("Pro Features", features: proFeatures, color: .purple)
                            }
                            
                            // Enterprise features
                            if showEnterpriseFeatures {
                                featuresSection("Enterprise Features", features: enterpriseFeatures, color: .green)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Change Plan") {
                        showPlanPurchase = true
                    }
                }
            }
            .sheet(isPresented: $showPlanPurchase) {
                PlanPurchaseView()
            }
            .onAppear {
                loadFeatureFlags()
            }
        }
    }
    
    private var currentPlanHeader: some View {
        VStack(spacing: 10) {
            Text("Current Plan: \(userState.plan.displayName)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(customDashboardColor)
            
            Text("Here are the features available to you")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Divider()
                .padding(.vertical)
        }
    }
    
    private func featuresSection(_ title: String, features: [String], color: Color) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(title)
                .font(.headline)
                .foregroundColor(color)
            
            ForEach(features, id: \.self) { feature in
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(color)
                    
                    Text(feature)
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                .padding(.vertical, 5)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .shadow(color: Color.gray.opacity(0.2), radius: 5, x: 0, y: 2)
        )
    }
    
    private func loadFeatureFlags() {
        isLoadingFeatureFlags = true
        
        // First, ensure PostHog has the latest user ID
        PostHogSDK.shared.identify(
            userState.userId,
            userProperties: [:]  // Don't set plan here, it will be set based on feature flag
        )
        
        // Flush to ensure the identify call is processed
        PostHogSDK.shared.flush()
        
        // Reload feature flags and check flag values after they're ready
        PostHogSDK.shared.reloadFeatureFlags {
            // First check if there's a user-plan feature flag that should override the current plan
            if let userPlan = PostHogSDK.shared.getFeatureFlag("user-plan") as? String,
               let planType = PlanType(rawValue: userPlan) {
                // Only update if the plan is different
                if planType != userState.plan {
                    print("Updating plan from feature flag: \(planType.displayName)")
                    userState.updatePlan(planType)
                    
                    // Update the plan in PostHog properties
                    PostHogSDK.shared.identify(
                        userState.userId,
                        userProperties: [
                            "plan": planType.rawValue
                        ]
                    )
                }
            }
            
            // Boolean feature flag check
            self.showProFeatures = PostHogSDK.shared.isFeatureEnabled("show-pro-features")
            
            // Another boolean feature flag check
            self.showEnterpriseFeatures = PostHogSDK.shared.isFeatureEnabled("show-enterprise-features")
            
            // Multivariate feature flag check
            if let colorValue = PostHogSDK.shared.getFeatureFlag("dashboard-color") as? String {
                switch colorValue {
                case "red": self.customDashboardColor = .red
                case "green": self.customDashboardColor = .green
                case "purple": self.customDashboardColor = .purple
                default: self.customDashboardColor = .blue
                }
                
                // Optional: getting the payload example
                let colorPayload = PostHogSDK.shared.getFeatureFlagPayload("dashboard-color")
                print("Dashboard color payload: \(String(describing: colorPayload))")
            }
            
            // Log the feature flag evaluations for debugging
            PostHogSDK.shared.capture("dashboard_loaded", properties: [
                "show_pro_features": self.showProFeatures,
                "show_enterprise_features": self.showEnterpriseFeatures,
                "dashboard_color": self.customDashboardColor.description,
                "current_plan": userState.plan.rawValue
            ])
            
            // Update the loading state
            self.isLoadingFeatureFlags = false
        }
    }
    
    // Sample features for each plan level
    private var standardFeatures: [String] {
        [
            "Basic analytics",
            "Up to 5 projects",
            "Standard support",
            "Community access"
        ]
    }
    
    private var proFeatures: [String] {
        [
            "Advanced analytics",
            "Up to 20 projects",
            "Email support",
            "API access",
            "Team collaboration"
        ]
    }
    
    private var enterpriseFeatures: [String] {
        [
            "Unlimited projects",
            "Priority support",
            "Custom integrations",
            "Dedicated account manager",
            "SLA guarantees",
            "Advanced security"
        ]
    }
} 