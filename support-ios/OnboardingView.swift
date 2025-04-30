import SwiftUI
import PostHog

struct OnboardingFeature {
    let title: String
    let description: String
    let icon: String
    let color: Color
}

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentPage = 0
    @State private var username = ""
    @State private var isPresentingUsername = false
    
    // Demo features to showcase
    private let features = [
        OnboardingFeature(
            title: "Analytics & Events",
            description: "Track user interactions and custom events to understand how your app is used",
            icon: "chart.bar",
            color: AppDesign.Colors.primaryOrange
        ),
        OnboardingFeature(
            title: "Feature Flags",
            description: "Control features and roll out updates gradually based on user segments",
            icon: "switch.2",
            color: AppDesign.Colors.standard
        ),
        OnboardingFeature(
            title: "Session Replay",
            description: "See how users interact with your app to improve user experience",
            icon: "video",
            color: AppDesign.Colors.pro
        ),
        OnboardingFeature(
            title: "Experiments",
            description: "A/B test different versions of your features to optimize performance",
            icon: "text.magnifyingglass",
            color: AppDesign.Colors.enterprise
        )
    ]
    
    var body: some View {
        ZStack {
            AppDesign.Colors.background
                .ignoresSafeArea()
            
            VStack(spacing: AppDesign.Spacing.small) {
                // Header
                headerView
                
                // Feature carousel
                TabView(selection: $currentPage) {
                    ForEach(0..<features.count, id: \.self) { index in
                        featureCard(features[index])
                            .tag(index)
                    }
                    
                    // Final card
                    getStartedCard
                        .tag(features.count)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                .animation(.easeInOut, value: currentPage)
                
                // Navigation buttons
                navigationButtons
                
                // Username input (only on last page)
                if currentPage == features.count && isPresentingUsername {
                    usernameInputView
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .animation(.easeInOut, value: isPresentingUsername)
                }
            }
            .padding(AppDesign.Spacing.small)
        }
        .onAppear {
            // Track onboarding view
            PostHogSDK.shared.capture("onboarding_started")
        }
    }
    
    private var headerView: some View {
        VStack(spacing: AppDesign.Spacing.small) {
            Image(systemName: "swift")
                .font(.system(size: 40))
                .foregroundColor(AppDesign.Colors.primaryOrange)
                .padding(AppDesign.Spacing.medium)
                .background(
                    Circle()
                        .fill(AppDesign.Colors.primaryOrange.opacity(0.1))
                )
            
            Text("PostHog iOS Showcase")
                .font(AppDesign.Typography.titleText)
                .foregroundColor(AppDesign.Colors.text)
            
            Text("Learn how to implement PostHog features in your iOS app")
                .font(AppDesign.Typography.bodyText)
                .foregroundColor(AppDesign.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .lineLimit(2)
        }
        .padding(.top, AppDesign.Spacing.medium)
    }
    
    private func featureCard(_ feature: OnboardingFeature) -> some View {
        VStack(spacing: AppDesign.Spacing.medium) {
            Image(systemName: feature.icon)
                .font(.system(size: 36))
                .foregroundColor(feature.color)
                .padding()
                .background(
                    Circle()
                        .fill(feature.color.opacity(0.15))
                )
            
            Text(feature.title)
                .font(AppDesign.Typography.titleText)
                .foregroundColor(AppDesign.Colors.text)
            
            Text(feature.description)
                .font(AppDesign.Typography.bodyText)
                .foregroundColor(AppDesign.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .lineLimit(2)
            
            codeSnippetView(for: feature.title)
                .padding(.top, AppDesign.Spacing.small)
        }
        .padding(AppDesign.Spacing.medium)
        .cardStyle()
        .padding(.horizontal, AppDesign.Spacing.medium)
    }
    
    private var getStartedCard: some View {
        VStack(spacing: AppDesign.Spacing.medium) {
            Image(systemName: "play.fill")
                .font(.system(size: 36))
                .foregroundColor(AppDesign.Colors.success)
                .padding()
                .background(
                    Circle()
                        .fill(AppDesign.Colors.success.opacity(0.15))
                )
            
            Text("Ready to Explore")
                .font(AppDesign.Typography.titleText)
                .foregroundColor(AppDesign.Colors.text)
            
            Text("Set up your profile to start exploring the PostHog Showcase App")
                .font(AppDesign.Typography.bodyText)
                .foregroundColor(AppDesign.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .lineLimit(2)
            
            VStack(alignment: .leading, spacing: AppDesign.Spacing.small) {
                Text("What you'll see:")
                    .font(AppDesign.Typography.headline)
                    .foregroundColor(AppDesign.Colors.text)
                
                featureRow(icon: "1.circle.fill", text: "Real-time analytics dashboard")
                featureRow(icon: "2.circle.fill", text: "Feature flag examples")
                featureRow(icon: "3.circle.fill", text: "Session replay demonstration")
                featureRow(icon: "4.circle.fill", text: "Code snippets for implementation")
            }
            .padding(AppDesign.Spacing.medium)
            .background(AppDesign.Colors.background)
            .cornerRadius(AppDesign.Radius.medium)
        }
        .padding(AppDesign.Spacing.medium)
        .cardStyle()
        .padding(.horizontal, AppDesign.Spacing.medium)
    }
    
    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: AppDesign.Spacing.small) {
            Image(systemName: icon)
                .foregroundColor(AppDesign.Colors.primaryOrange)
                .font(.system(size: 14))
            
            Text(text)
                .font(AppDesign.Typography.caption)
                .foregroundColor(AppDesign.Colors.text)
        }
    }
    
    private var navigationButtons: some View {
        HStack {
            // Back button
            Button(action: {
                if currentPage > 0 {
                    currentPage -= 1
                    PostHogSDK.shared.capture("onboarding_previous_page", properties: [
                        "page_index": currentPage
                    ])
                }
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(currentPage > 0 ? AppDesign.Colors.primaryOrange : .gray)
                    .padding()
            }
            .disabled(currentPage == 0)
            
            Spacer()
            
            // Next/Get Started button
            Button(action: {
                if currentPage < features.count {
                    currentPage += 1
                    PostHogSDK.shared.capture("onboarding_next_page", properties: [
                        "page_index": currentPage
                    ])
                } else {
                    // On the final card, show username input
                    isPresentingUsername = true
                    PostHogSDK.shared.capture("onboarding_get_started_clicked")
                }
            }) {
                Text(currentPage < features.count ? "Next" : "Get Started")
                    .padding(.horizontal, AppDesign.Spacing.medium)
                    .padding(.vertical, AppDesign.Spacing.small)
            }
            .primaryButton()
        }
        .padding(.horizontal)
    }
    
    private var usernameInputView: some View {
        VStack(spacing: AppDesign.Spacing.small) {
            Text("Create your profile")
                .font(AppDesign.Typography.headline)
                .foregroundColor(AppDesign.Colors.text)
            
            TextField("Your username", text: $username)
                .padding()
                .background(AppDesign.Colors.card)
                .cornerRadius(AppDesign.Radius.medium)
                .overlay(
                    RoundedRectangle(cornerRadius: AppDesign.Radius.medium)
                        .stroke(AppDesign.Colors.border, lineWidth: 1)
                )
            
            Button(action: {
                completeOnboarding()
            }) {
                Text("Start Exploring")
                    .padding(.horizontal, AppDesign.Spacing.medium)
                    .padding(.vertical, AppDesign.Spacing.small)
                    .frame(maxWidth: .infinity)
            }
            .primaryButton()
            .disabled(username.isEmpty)
            .opacity(username.isEmpty ? 0.7 : 1.0)
        }
        .padding()
        .cardStyle()
    }
    
    private func completeOnboarding() {
        guard !username.isEmpty else { return }
        
        // Set up user identification
        let userProperties: [String: Any] = [
            "initial_plan": "standard",
            "onboarding_completed": true,
            "onboarding_completion_date": Date().ISO8601Format()
        ]
        
        // Identify the user
        PostHogSDK.shared.identify(username, userProperties: userProperties)
        
        // Track completion
        PostHogSDK.shared.capture("onboarding_completed", properties: [
            "username": username
        ])
        
        // Flush events to ensure they're sent immediately
        PostHogSDK.shared.flush()
        
        // Complete onboarding
        hasCompletedOnboarding = true
    }
    
    private func codeSnippetView(for feature: String) -> some View {
        let code = codeSnippet(for: feature)
        
        return VStack(alignment: .leading, spacing: AppDesign.Spacing.tiny) {
            Text("Example Implementation:")
                .font(AppDesign.Typography.caption)
                .foregroundColor(AppDesign.Colors.textSecondary)
            
            Text(code)
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(AppDesign.Colors.text)
                .lineLimit(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppDesign.Spacing.small)
        .background(Color(.systemGray6))
        .cornerRadius(AppDesign.Radius.medium)
    }
    
    private func codeSnippet(for feature: String) -> String {
        switch feature {
        case "Analytics & Events":
            return """
            // Track custom event
            PostHogSDK.shared.capture(
              "button_clicked",
              properties: ["button_id": "signup"]
            )
            """
        case "Feature Flags":
            return """
            // Check feature flag value
            if let flagValue = PostHogSDK.shared.getFeatureFlag(
              "new-onboarding") as? Bool, flagValue {
                // Show new onboarding flow
            }
            """
        case "Session Replay":
            return """
            // Enable session replay in your config
            let config = PostHogConfig(apiKey: "YOUR_API_KEY")
            config.sessionReplay = true
            config.sessionReplayConfig.screenshotMode = true
            """
        default: // Experiments
            return """
            // A/B Test with feature flags
            let variant = PostHogSDK.shared.getFeatureFlag(
              "button-color") as? String
            
            switch variant {
            case "red": showRedButton()
            case "blue": showBlueButton()
            default: showDefaultButton()
            }
            """
        }
    }
} 