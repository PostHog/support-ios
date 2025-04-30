import SwiftUI
import PostHog

struct SettingsView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @EnvironmentObject var userState: UserState
    @State private var showResetConfirmation = false
    
    var body: some View {
        NavigationView {
            ZStack {
                AppDesign.Colors.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: AppDesign.Spacing.large) {
                        // User profile section
                        profileSection
                        
                        // App settings section
                        appSettingsSection
                        
                        // Reset section
                        resetSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Settings")
            .alert("Reset Onboarding", isPresented: $showResetConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    resetOnboarding()
                }
            } message: {
                Text("This will restart the app at the onboarding screen. Are you sure?")
            }
            .onAppear {
                // Track screen view
                PostHogSDK.shared.capture("settings_view_opened")
            }
        }
    }
    
    private var profileSection: some View {
        VStack(alignment: .leading, spacing: AppDesign.Spacing.medium) {
            Text("Profile")
                .font(AppDesign.Typography.headline)
                .foregroundColor(AppDesign.Colors.text)
            
            HStack {
                VStack(alignment: .leading, spacing: AppDesign.Spacing.small) {
                    Text("Username")
                        .font(AppDesign.Typography.caption)
                        .foregroundColor(AppDesign.Colors.textSecondary)
                    
                    Text(userState.userId)
                        .font(AppDesign.Typography.bodyText)
                        .foregroundColor(AppDesign.Colors.text)
                }
                
                Spacer()
                
                Circle()
                    .fill(userState.plan.color)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(String(userState.userId.prefix(1)).uppercased())
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                    )
            }
            
            Divider()
            
            HStack {
                VStack(alignment: .leading, spacing: AppDesign.Spacing.small) {
                    Text("Current Plan")
                        .font(AppDesign.Typography.caption)
                        .foregroundColor(AppDesign.Colors.textSecondary)
                    
                    Text(userState.plan.displayName)
                        .font(AppDesign.Typography.bodyText)
                        .foregroundColor(AppDesign.Colors.text)
                }
                
                Spacer()
                
                NavigationLink(destination: PlanPurchaseView()) {
                    Text("Change")
                        .font(AppDesign.Typography.button)
                        .foregroundColor(AppDesign.Colors.primaryOrange)
                }
            }
        }
        .padding()
        .background(AppDesign.Colors.card)
        .cornerRadius(AppDesign.Radius.large)
        .shadow(color: AppDesign.Shadows.small, radius: AppDesign.Shadows.smallRadius, x: 0, y: 1)
    }
    
    private var appSettingsSection: some View {
        VStack(alignment: .leading, spacing: AppDesign.Spacing.medium) {
            Text("App Settings")
                .font(AppDesign.Typography.headline)
                .foregroundColor(AppDesign.Colors.text)
            
            // App version info
            HStack {
                Text("App Version")
                    .font(AppDesign.Typography.bodyText)
                    .foregroundColor(AppDesign.Colors.text)
                
                Spacer()
                
                Text("1.0.0")
                    .font(AppDesign.Typography.bodyText)
                    .foregroundColor(AppDesign.Colors.textSecondary)
            }
            .padding(.vertical, AppDesign.Spacing.small)
        }
        .padding()
        .background(AppDesign.Colors.card)
        .cornerRadius(AppDesign.Radius.large)
        .shadow(color: AppDesign.Shadows.small, radius: AppDesign.Shadows.smallRadius, x: 0, y: 1)
    }
    
    private var resetSection: some View {
        VStack(alignment: .leading, spacing: AppDesign.Spacing.medium) {
            Text("Development Options")
                .font(AppDesign.Typography.headline)
                .foregroundColor(AppDesign.Colors.text)
            
            Button(action: {
                showResetConfirmation = true
            }) {
                HStack {
                    Image(systemName: "arrow.counterclockwise.circle")
                        .foregroundColor(AppDesign.Colors.error)
                    
                    Text("Reset Onboarding")
                        .foregroundColor(AppDesign.Colors.error)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(AppDesign.Colors.textSecondary)
                }
            }
            .padding(.vertical, AppDesign.Spacing.small)
        }
        .padding()
        .background(AppDesign.Colors.card)
        .cornerRadius(AppDesign.Radius.large)
        .shadow(color: AppDesign.Shadows.small, radius: AppDesign.Shadows.smallRadius, x: 0, y: 1)
    }
    
    private func resetOnboarding() {
        // Track reset action
        PostHogSDK.shared.capture("reset_onboarding_clicked")
        PostHogSDK.shared.flush()
        
        // Reset onboarding state
        hasCompletedOnboarding = false
    }
} 