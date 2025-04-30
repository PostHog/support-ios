import SwiftUI
import PostHog

struct PlanPurchaseView: View {
    @EnvironmentObject var userState: UserState
    @State private var selectedPlan: PlanType = .standard
    @State private var showPurchaseConfirmation = false
    @State private var showUpgradeModal = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            AppDesign.Colors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with close button
                HStack {
                    Text("Choose Your Plan")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(AppDesign.Colors.textSecondary)
                    }
                }
                .padding()
                
                // Plan cards in a scrollable area
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(PlanType.allCases) { plan in
                            PlanCard(plan: plan, isSelected: selectedPlan == plan)
                                .onTapGesture {
                                    selectedPlan = plan
                                }
                        }
                    }
                    .padding(.bottom, 100) // Extra padding at bottom to make sure last card is visible above the button
                }
                
                // Fixed purchase button container at the bottom
                VStack {
                    Button(action: {
                        showPurchaseConfirmation = true
                    }) {
                        Text("Purchase \(selectedPlan.displayName) Plan")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(selectedPlan.color)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8) // Safe padding for bottom area
                }
                .background(
                    Rectangle()
                        .fill(AppDesign.Colors.background)
                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: -2)
                )
            }
        }
        .alert("Confirm Purchase", isPresented: $showPurchaseConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Purchase") {
                completePurchase()
            }
        } message: {
            Text("Would you like to purchase the \(selectedPlan.displayName) plan for $\(selectedPlan.price)/month?")
        }
        .sheet(isPresented: $showUpgradeModal) {
            UpgradeModalView(plan: selectedPlan)
                .environmentObject(userState)
        }
    }
    
    private func completePurchase() {
        // Update user plan locally
        userState.updatePlan(selectedPlan)
        
        // Track the purchase event with plan information
        PostHogSDK.shared.capture("plan_purchased", properties: [
            "plan_type": selectedPlan.rawValue,
            "plan_price": selectedPlan.price,
            "plan": selectedPlan.rawValue // Include plan property to update user properties
        ])
        
        // Update user properties in PostHog with the new plan
        // userState.userId is the same as username from login since LoginView updates it
        PostHogSDK.shared.identify(
            userState.userId,
            userProperties: [
                "plan": selectedPlan.rawValue
            ]
        )
        
        // Flush to ensure the identify call is sent immediately
        PostHogSDK.shared.flush()
        
        // Reload feature flags to get the latest based on new plan
        // This is required for iOS SDK as flag values are cached
        PostHogSDK.shared.reloadFeatureFlags()
        
        // Now check the updated flag value
        if let planFeatures = PostHogSDK.shared.getFeatureFlag("plan-features") as? String {
            if planFeatures == "pro" || planFeatures == "enterprise" {
                showUpgradeModal = true
            } else {
                dismiss()
            }
        } else {
            // If flag isn't available, base decision on the selected plan
            if selectedPlan == .pro || selectedPlan == .enterprise {
                showUpgradeModal = true
            } else {
                dismiss()
            }
        }
    }
}

struct PlanCard: View {
    let plan: PlanType
    let isSelected: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(plan.displayName)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text("$\(plan.price)/mo")
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            
            Divider()
            
            planFeatures
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: isSelected ? plan.color.opacity(0.5) : Color.gray.opacity(0.2), 
                        radius: isSelected ? 8 : 2, 
                        x: 0, 
                        y: isSelected ? 4 : 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? plan.color : Color.clear, lineWidth: 2)
        )
        .padding(.horizontal)
    }
    
    private var planFeatures: some View {
        VStack(alignment: .leading, spacing: 8) {
            featureRow("Basic features", included: true)
            
            if plan == .pro || plan == .enterprise {
                featureRow("Advanced analytics", included: true)
            } else {
                featureRow("Advanced analytics", included: false)
            }
            
            if plan == .enterprise {
                featureRow("Priority support", included: true)
                featureRow("Custom integrations", included: true)
            } else {
                featureRow("Priority support", included: false)
                featureRow("Custom integrations", included: false)
            }
        }
    }
    
    private func featureRow(_ text: String, included: Bool) -> some View {
        HStack(spacing: 10) {
            Image(systemName: included ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(included ? .green : .gray)
            
            Text(text)
                .foregroundColor(included ? .primary : .gray)
            
            Spacer()
        }
    }
}

struct UpgradeModalView: View {
    let plan: PlanType
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userState: UserState
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "star.circle.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(plan.color)
                .padding(.top, 30)
            
            Text("Welcome to \(plan.displayName)!")
                .font(.title)
                .fontWeight(.bold)
            
            Text("You've successfully upgraded to our \(plan.displayName) plan.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Text("New features are now available in your dashboard.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Continue to Dashboard") {
                // Track that user clicked on dashboard button
                PostHogSDK.shared.capture("upgrade_dashboard_clicked")
                
                // First dismiss this modal
                dismiss()
                
                // Give time for dismiss to complete before dismissing parent
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    // Then dismiss the plan purchase view and go to dashboard
                    NotificationCenter.default.post(name: .navigateToDashboard, object: nil)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(plan.color)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal, 40)
            .padding(.top, 20)
            
            Spacer()
        }
        .padding()
        .onAppear {
            // Track that the modal was shown
            PostHogSDK.shared.capture("upgrade_modal_shown", properties: [
                "plan_type": plan.rawValue,
                "plan": plan.rawValue // Include plan property to update user properties
            ])
        }
    }
}

// Add notification name for dashboard navigation
extension Notification.Name {
    static let navigateToDashboard = Notification.Name("navigateToDashboard")
} 