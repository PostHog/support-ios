import SwiftUI
import PostHog

/// Showcase feature type for the feature explorer 
struct ShowcaseFeature: Identifiable {
    var id = UUID()
    let title: String
    let description: String
    let icon: String
    let color: Color
    let destinationView: AnyView
    let requiredPlan: PlanType
    
    init(title: String, description: String, icon: String, color: Color, destinationView: AnyView, requiredPlan: PlanType = .standard) {
        self.title = title
        self.description = description
        self.icon = icon
        self.color = color
        self.destinationView = destinationView
        self.requiredPlan = requiredPlan
    }
}

struct FeatureShowcaseView: View {
    @EnvironmentObject var userState: UserState
    @State private var isLoadingFeatureFlags = true
    @State private var searchText = ""
    @State private var showPlanPurchase = false
    
    // All available features in the showcase
    private var allFeatures: [ShowcaseFeature] {
        [
            ShowcaseFeature(
                title: "Event Tracking",
                description: "Track user actions and custom events to understand how your app is used",
                icon: "chart.bar",
                color: AppDesign.Colors.standard,
                destinationView: AnyView(EventTrackingView())
            ),
            ShowcaseFeature(
                title: "User Properties",
                description: "Capture and update user attributes to segment your audience",
                icon: "person.fill",
                color: AppDesign.Colors.standard,
                destinationView: AnyView(TypingView())
            ),
            ShowcaseFeature(
                title: "Session Replay",
                description: "Record and review user sessions to understand behaviors and pain points",
                icon: "video.fill",
                color: AppDesign.Colors.pro,
                destinationView: AnyView(ScrollingView()),
                requiredPlan: .pro
            ),
            ShowcaseFeature(
                title: "Feature Flags",
                description: "Control feature access and run experiments with targeted rollouts",
                icon: "switch.2",
                color: AppDesign.Colors.pro,
                destinationView: AnyView(FeatureFlagsExampleView()),
                requiredPlan: .pro
            ),
            ShowcaseFeature(
                title: "A/B Testing",
                description: "Test different variations of your features to optimize performance",
                icon: "arrow.triangle.branch",
                color: AppDesign.Colors.enterprise,
                destinationView: AnyView(Text("A/B Testing")),
                requiredPlan: .enterprise
            ),
            ShowcaseFeature(
                title: "Funnels & Retention",
                description: "Analyze user journeys and measure how well you retain users",
                icon: "chart.xyaxis.line",
                color: AppDesign.Colors.enterprise,
                destinationView: AnyView(Text("Funnels & Retention")),
                requiredPlan: .enterprise
            )
        ]
    }
    
    // Filtered features based on search and plan
    private var filteredFeatures: [ShowcaseFeature] {
        let planFiltered = allFeatures.filter { feature in
            switch userState.plan {
            case .enterprise:
                return true // All features available
            case .pro:
                return feature.requiredPlan != .enterprise
            case .standard:
                return feature.requiredPlan == .standard
            }
        }
        
        if searchText.isEmpty {
            return planFiltered
        } else {
            return planFiltered.filter { feature in
                feature.title.lowercased().contains(searchText.lowercased()) ||
                feature.description.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppDesign.Colors.background
                    .ignoresSafeArea()
                
                if isLoadingFeatureFlags {
                    ProgressView("Loading features...")
                        .foregroundColor(AppDesign.Colors.text)
                } else {
                    VStack {
                        searchField
                        
                        if filteredFeatures.isEmpty {
                            noResultsView
                        } else {
                            featureList
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Feature Explorer")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Change Plan") {
                        showPlanPurchase = true
                    }
                }
            }
            .sheet(isPresented: $showPlanPurchase) {
                PlanPurchaseView()
                    .environmentObject(userState)
            }
            .onAppear {
                loadFeatureFlags()
                trackScreenView()
            }
        }
    }
    
    private var searchField: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AppDesign.Colors.textSecondary)
            
            TextField("Search features", text: $searchText)
                .font(AppDesign.Typography.bodyText)
                .foregroundColor(AppDesign.Colors.text)
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppDesign.Colors.textSecondary)
                }
            }
        }
        .padding()
        .background(AppDesign.Colors.card)
        .cornerRadius(AppDesign.Radius.medium)
        .padding(.bottom, AppDesign.Spacing.medium)
    }
    
    private var featureList: some View {
        ScrollView {
            VStack(spacing: AppDesign.Spacing.medium) {
                // Current plan info
                currentPlanBanner
                
                // Features grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: AppDesign.Spacing.medium) {
                    ForEach(filteredFeatures) { feature in
                        NavigationLink(destination: featureDetailView(for: feature)) {
                            featureCard(feature)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
    }
    
    private var currentPlanBanner: some View {
        HStack {
            VStack(alignment: .leading, spacing: AppDesign.Spacing.small) {
                Text("Current Plan: \(userState.plan.displayName)")
                    .font(AppDesign.Typography.headline)
                    .foregroundColor(AppDesign.Colors.text)
                
                Text("You have access to \(filteredFeatures.count) of \(allFeatures.count) features")
                    .font(AppDesign.Typography.caption)
                    .foregroundColor(AppDesign.Colors.textSecondary)
            }
            
            Spacer()
            
            Circle()
                .fill(userState.plan.color)
                .frame(width: 30, height: 30)
        }
        .padding()
        .background(userState.plan.color.opacity(0.1))
        .cornerRadius(AppDesign.Radius.medium)
    }
    
    private var noResultsView: some View {
        VStack(spacing: AppDesign.Spacing.large) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(AppDesign.Colors.textSecondary)
            
            Text("No matching features found")
                .font(AppDesign.Typography.titleText)
                .foregroundColor(AppDesign.Colors.text)
            
            Text("Try adjusting your search or upgrading your plan to access more features")
                .font(AppDesign.Typography.bodyText)
                .foregroundColor(AppDesign.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding()
            
            Button(action: {
                showPlanPurchase = true
            }) {
                Text("View Available Plans")
                    .padding(.horizontal, AppDesign.Spacing.large)
                    .padding(.vertical, AppDesign.Spacing.medium)
            }
            .secondaryButton()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func featureCard(_ feature: ShowcaseFeature) -> some View {
        VStack(alignment: .leading, spacing: AppDesign.Spacing.medium) {
            // Icon
            Image(systemName: feature.icon)
                .font(.system(size: 24))
                .foregroundColor(.white)
                .frame(width: 48, height: 48)
                .background(feature.color)
                .cornerRadius(AppDesign.Radius.medium)
            
            // Title
            Text(feature.title)
                .font(AppDesign.Typography.headline)
                .foregroundColor(AppDesign.Colors.text)
                .lineLimit(1)
            
            // Description
            Text(feature.description)
                .font(AppDesign.Typography.caption)
                .foregroundColor(AppDesign.Colors.textSecondary)
                .lineLimit(3)
            
            Spacer()
            
            // Plan indicator
            HStack {
                Text(feature.requiredPlan.displayName)
                    .font(AppDesign.Typography.caption)
                    .padding(.horizontal, AppDesign.Spacing.small)
                    .padding(.vertical, 4)
                    .background(feature.requiredPlan.color.opacity(0.1))
                    .foregroundColor(feature.requiredPlan.color)
                    .cornerRadius(AppDesign.Radius.small)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(AppDesign.Colors.textSecondary)
            }
        }
        .padding()
        .frame(height: 200)
        .background(AppDesign.Colors.card)
        .cornerRadius(AppDesign.Radius.large)
        .shadow(color: AppDesign.Shadows.small, radius: AppDesign.Shadows.smallRadius, x: 0, y: 1)
    }
    
    private func featureDetailView(for feature: ShowcaseFeature) -> some View {
        VStack(spacing: 0) {
            // Compact header with icon and title only
            HStack {
                Image(systemName: feature.icon)
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .frame(width: 48, height: 48)
                    .background(feature.color)
                    .cornerRadius(AppDesign.Radius.medium)
                
                Text(feature.title)
                    .font(AppDesign.Typography.headline)
                    .foregroundColor(AppDesign.Colors.text)
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, AppDesign.Spacing.medium)
            .padding(.bottom, AppDesign.Spacing.medium)
            
            // Demo content - full width
            feature.destinationView
                .edgesIgnoringSafeArea(.bottom)
        }
        .navigationTitle(feature.title)
        .onAppear {
            // POSTHOG: Track which features users are viewing with contextual properties
            // This helps understand feature popularity and usage by different plan levels
            PostHogSDK.shared.capture("feature_viewed", properties: [
                "feature_name": feature.title,
                "required_plan": feature.requiredPlan.rawValue
            ])
        }
    }
    
    private func loadFeatureFlags() {
        isLoadingFeatureFlags = true
        
        // POSTHOG: Reload feature flags to get the latest configuration
        // This is particularly important when determining feature access
        PostHogSDK.shared.reloadFeatureFlags()
        
        // Add a slight delay to ensure flags are loaded
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // POSTHOG: Check for plan-level feature flag to determine user access
            // This demonstrates using feature flags to control user experience based on plan tier
            if let planFeatures = PostHogSDK.shared.getFeatureFlag("plan-features") as? String,
               let planType = PlanType(rawValue: planFeatures) {
                // Update user state with plan from feature flag
                userState.updatePlan(planType)
            }
            
            // POSTHOG: Implement a fallback mechanism for feature flags
            // This is a best practice to handle cases where feature flags might fail
            if let showFallback = PostHogSDK.shared.getFeatureFlag("show-fallback") as? Bool, showFallback {
                // Display fallback features for all plans (would be implemented in production)
                print("Using fallback feature set due to feature flag setting")
            }
            
            // Update loading state
            isLoadingFeatureFlags = false
        }
    }
    
    private func trackScreenView() {
        // POSTHOG: Track screen views with additional context
        // This provides richer analytics than automatic screen tracking
        PostHogSDK.shared.capture("screen_viewed", properties: [
            "screen_name": "Feature Explorer",
            "current_plan": userState.plan.rawValue
        ])
    }
} 