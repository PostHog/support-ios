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
            description: "Track user interactions to understand app usage patterns",
            icon: "chart.bar",
            color: AppDesign.Colors.primaryOrange
        ),
        OnboardingFeature(
            title: "Feature Flags",
            description: "Control features and roll out updates gradually",
            icon: "switch.2",
            color: AppDesign.Colors.standard
        ),
        OnboardingFeature(
            title: "Session Replay",
            description: "See how users interact with your app to improve UX",
            icon: "video",
            color: AppDesign.Colors.pro
        ),
        OnboardingFeature(
            title: "Experiments",
            description: "A/B test different versions of your features",
            icon: "text.magnifyingglass",
            color: AppDesign.Colors.enterprise
        )
    ]
    
    var body: some View {
        ZStack {
            AppDesign.Colors.background
                .ignoresSafeArea()
            
            if currentPage == features.count && isPresentingUsername {
                // Show only the username form when "Get Started" is clicked
                VStack {
                    // Header
                    headerView
                    
                    Spacer()
                    
                    // Username input form
                    usernameInputView
                    
                    Spacer()
                }
                .padding(AppDesign.Spacing.medium)
                .transition(.opacity)
                .animation(.easeInOut, value: isPresentingUsername)
            } else {
                // Normal onboarding flow
                VStack {
                    // Header
                    headerView
                    
                    Spacer() // Push content toward center
                    
                    // Feature carousel in center
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
                    .frame(height: 320)
                    
                    Spacer() // Maintain center position
                    
                    // Navigation buttons are fixed at bottom
                    VStack {
                        navigationButtons
                    }
                    .padding(.bottom, AppDesign.Spacing.small)
                }
                .padding(AppDesign.Spacing.medium)
            }
        }
        .onAppear {
            // Track onboarding view
            PostHogSDK.shared.capture("onboarding_started")
        }
    }
    
    private var headerView: some View {
        VStack(spacing: AppDesign.Spacing.small) {
            // Swift logo instead of SF Symbol
            ZStack {
                Circle()
                    .fill(AppDesign.Colors.primaryOrange.opacity(0.1))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "swift")
                    .font(.system(size: 36))
                    .foregroundColor(AppDesign.Colors.primaryOrange)
            }
            
            Text("PostHog iOS Showcase")
                .font(AppDesign.Typography.titleText)
                .foregroundColor(AppDesign.Colors.text)
            
            Text("Learn how to implement PostHog features in your iOS app")
                .font(AppDesign.Typography.bodyText)
                .foregroundColor(AppDesign.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .fixedSize(horizontal: false, vertical: true) // Allow text to expand vertically
        }
        .padding(.top, AppDesign.Spacing.medium)
        .padding(.bottom, AppDesign.Spacing.small)
    }
    
    private func featureCard(_ feature: OnboardingFeature) -> some View {
        VStack {
            Spacer()
            
            // Icon at the top
            ZStack {
                Circle()
                    .fill(feature.color.opacity(0.15))
                    .frame(width: 70, height: 70)
                
                Image(systemName: feature.icon)
                    .font(.system(size: 30))
                    .foregroundColor(feature.color)
            }
            
            // Title
            Text(feature.title)
                .font(AppDesign.Typography.titleText)
                .foregroundColor(AppDesign.Colors.text)
                .padding(.top, AppDesign.Spacing.medium)
            
            // Description - main focus
            Text(feature.description)
                .font(AppDesign.Typography.bodyText)
                .foregroundColor(AppDesign.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppDesign.Spacing.large)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, AppDesign.Spacing.small)
            
            Spacer()
        }
        .frame(width: UIScreen.main.bounds.width - 60, height: 280)
        .background(AppDesign.Colors.card)
        .cornerRadius(AppDesign.Radius.large)
        .shadow(color: AppDesign.Shadows.small, radius: AppDesign.Shadows.smallRadius, x: 0, y: 1)
    }
    
    private var getStartedCard: some View {
        VStack {
            Spacer()
            
            // Icon at the top
            ZStack {
                Circle()
                    .fill(AppDesign.Colors.success.opacity(0.15))
                    .frame(width: 70, height: 70)
                
                Image(systemName: "play.fill")
                    .font(.system(size: 30))
                    .foregroundColor(AppDesign.Colors.success)
            }
            
            // Title
            Text("Ready to Explore")
                .font(AppDesign.Typography.titleText)
                .foregroundColor(AppDesign.Colors.text)
                .padding(.top, AppDesign.Spacing.medium)
            
            // Description - main focus
            Text("Set up your profile to start exploring the PostHog Showcase App")
                .font(AppDesign.Typography.bodyText)
                .foregroundColor(AppDesign.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppDesign.Spacing.large)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, AppDesign.Spacing.small)
            
            Spacer()
        }
        .frame(width: UIScreen.main.bounds.width - 60, height: 280)
        .background(AppDesign.Colors.card)
        .cornerRadius(AppDesign.Radius.large)
        .shadow(color: AppDesign.Shadows.small, radius: AppDesign.Shadows.smallRadius, x: 0, y: 1)
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
            
            // Skip button
            if currentPage < features.count {
                Button(action: {
                    // Skip to the user profile form
                    currentPage = features.count
                    isPresentingUsername = true
                    PostHogSDK.shared.capture("onboarding_skipped", properties: [
                        "skipped_from_page": currentPage
                    ])
                }) {
                    Text("Skip")
                        .foregroundColor(AppDesign.Colors.textSecondary)
                }
                .ghostButton()
                .padding(.trailing, AppDesign.Spacing.medium)
            }
            
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
        VStack(spacing: AppDesign.Spacing.medium) {
            Text("Create your profile")
                .font(AppDesign.Typography.titleText)
                .foregroundColor(AppDesign.Colors.text)
                .padding(.bottom, AppDesign.Spacing.small)
            
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
            
            // Back button
            Button(action: {
                isPresentingUsername = false
            }) {
                Text("Back")
                    .padding(.top, AppDesign.Spacing.medium)
            }
            .ghostButton()
        }
        .padding(AppDesign.Spacing.large)
        .background(AppDesign.Colors.card)
        .cornerRadius(AppDesign.Radius.large)
        .shadow(color: AppDesign.Shadows.medium, radius: AppDesign.Shadows.mediumRadius, x: 0, y: 2)
        .padding(.horizontal, AppDesign.Spacing.medium)
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
} 