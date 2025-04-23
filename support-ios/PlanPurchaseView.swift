import SwiftUI
import PostHog

struct PlanPurchaseView: View {
    @EnvironmentObject var userState: UserState
    @State private var selectedPlan: PlanType = .standard
    @State private var showPurchaseConfirmation = false
    @State private var showFeatureFlagModal = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Choose Your Plan")
                .font(.largeTitle)
                .bold()
                .padding(.top)
            
            ForEach(PlanType.allCases) { plan in
                PlanCard(plan: plan, isSelected: selectedPlan == plan)
                    .onTapGesture {
                        selectedPlan = plan
                    }
            }
            
            Spacer()
            
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
            .padding(.bottom, 30)
        }
        .alert("Confirm Purchase", isPresented: $showPurchaseConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Purchase") {
                completePurchase()
            }
        } message: {
            Text("Would you like to purchase the \(selectedPlan.displayName) plan for $\(selectedPlan.price)/month?")
        }
        .sheet(isPresented: $showFeatureFlagModal) {
            UpgradeModalView(plan: selectedPlan)
        }
    }
    
    private func completePurchase() {
        // Update user plan
        userState.updatePlan(selectedPlan)
        
        // Track the purchase event with plan information
        PostHogSDK.shared.capture("plan_purchased", properties: [
            "plan_type": selectedPlan.rawValue,
            "plan_price": selectedPlan.price
        ])
        
        // Update user properties in PostHog
        PostHogSDK.shared.identify(
            userState.userId,
            userProperties: [
                "plan": selectedPlan.rawValue
            ]
        )
        
        // Send a server request to update the user's persisted plan
        // This event is used to signal that this user's plan should be persisted
        // The distinct_id (userState.userId) is already included automatically
        PostHogSDK.shared.capture("update_user_plan", properties: [
            "new_plan": selectedPlan.rawValue,
            "persist_plan": true
        ])
        
        // Flush to ensure all events are sent immediately
        PostHogSDK.shared.flush()
        
        // Reload feature flags and check if modal should be shown
        PostHogSDK.shared.reloadFeatureFlags {
            // Check boolean feature flag for showing modal after purchase
            if PostHogSDK.shared.isFeatureEnabled("show-upgrade-modal") {
                // Only show the modal if the feature flag is enabled
                showFeatureFlagModal = true
            } else {
                // If feature flag is disabled, just dismiss
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
                dismiss()
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
                "plan_type": plan.rawValue
            ])
        }
    }
} 