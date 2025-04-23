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
                // Always start in loading state on appear
                isLoadingFeatureFlags = true
                // Use async to ensure UI shows loading first
                DispatchQueue.main.async {
                    loadFeatureFlags()
                }
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
        print("Loading feature flags for Dashboard")
        
        // Explicitly reload feature flags to ensure we have the latest values
        // This is required for iOS SDK as flag values are cached
        PostHogSDK.shared.reloadFeatureFlags()
        
        // Add a slight delay to ensure flags are loaded
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Check for the plan-features flag
            if let planFeatures = PostHogSDK.shared.getFeatureFlag("plan-features") as? String,
               let planType = PlanType(rawValue: planFeatures) {
                
                // Update the user state with the plan from feature flag
                userState.updatePlan(planType)
                
                // Set feature visibility based on the feature flag value
                switch planFeatures {
                case "pro":
                    self.showProFeatures = true
                    self.showEnterpriseFeatures = false
                    self.customDashboardColor = .purple
                case "enterprise":
                    self.showProFeatures = true
                    self.showEnterpriseFeatures = true
                    self.customDashboardColor = .green
                default: // standard or unknown
                    self.showProFeatures = false
                    self.showEnterpriseFeatures = false
                    self.customDashboardColor = .blue
                }
                
                print("Plan features from feature flag: \(planFeatures)")
            } else {
                // Default to standard if no flag is found
                userState.updatePlan(.standard)
                self.showProFeatures = false
                self.showEnterpriseFeatures = false
                self.customDashboardColor = .blue
                print("No plan-features flag found, using Standard")
            }
            
            // Log the flag evaluation for debugging
            PostHogSDK.shared.capture("dashboard_loaded", properties: [
                "show_pro_features": self.showProFeatures,
                "show_enterprise_features": self.showEnterpriseFeatures,
                "dashboard_color": self.customDashboardColor.description,
                "current_plan": userState.plan.rawValue
            ])
            
            // Update the loading state after everything is processed
            self.isLoadingFeatureFlags = false
            print("Dashboard finished loading flags, showing UI")
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