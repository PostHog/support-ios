# Feature Flags in iOS App

This document explains how we've implemented feature flags in our iOS test application to demonstrate PostHog's feature flagging capabilities.

## Overview

We use a feature flag approach to control UI elements and features based on a user's plan level (standard, pro, or enterprise). This allows us to test how consistently feature flags behave across app sessions and during user property changes.

## Implementation Details

### 1. Single Target-Based Feature Flag

We use a single multivariate feature flag called `plan-features` with three possible string values:

- `"standard"` - Default tier
- `"pro"` - Mid-tier
- `"enterprise"` - Top tier

This flag is targeted based on the user's `plan` property, which is sent with each event and during user identification.

### 2. Handling Feature Flag Loading

A key challenge with feature flags is handling the asynchronous loading process. We've implemented several strategies to ensure UI only renders when feature flags are properly loaded:

```swift
private func loadFeatureFlags() {
    // Start in loading state
    isLoadingFeatureFlags = true
    
    // Explicitly reload feature flags
    PostHogSDK.shared.reloadFeatureFlags()
    
    // Add a slight delay to ensure flags are loaded
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        // Now check the flag value
        if let planFeatures = PostHogSDK.shared.getFeatureFlag("plan-features") as? String {
            // Update UI based on flag value
            // ...
        }
        
        // Exit loading state when complete
        isLoadingFeatureFlags = false
    }
}
```

Each view implements:
1. A loading state with visual indicator
2. Explicit feature flag reloading
3. A small delay to ensure flags are processed
4. Flag value checking only after this delay

### 3. User Login Flow

When a user logs in, we:
1. Identify the user without setting a plan property (preserving their existing properties)
2. Reload feature flags to get the user's stored plan
3. Display loading indicators while flags are being fetched

```swift
// Identify user without setting plan - we'll get this from PostHog
PostHogSDK.shared.identify(username, userProperties: [...])

// Flush to ensure the identify call is sent immediately
PostHogSDK.shared.flush()

// Explicitly reload feature flags after login
PostHogSDK.shared.reloadFeatureFlags()
```

### 4. Plan Change Flow

When a user changes their plan:
1. Update the plan property via both `identify()` and `capture()` events
2. Explicitly reload feature flags to refresh values
3. Check the flag value after reloading

```swift
// Track the purchase event with plan information
PostHogSDK.shared.capture("plan_purchased", properties: [
    "plan": selectedPlan.rawValue // Include plan property
])

// Update user properties
PostHogSDK.shared.identify(userState.userId, userProperties: [
    "plan": selectedPlan.rawValue
])

// Flush and reload flags
PostHogSDK.shared.flush()
PostHogSDK.shared.reloadFeatureFlags()
```

## PostHog Setup

In PostHog, the `plan-features` flag should be set up as:

1. **Flag Type**: Multivariate String
2. **Variants**: 
   - `"standard"` (default)
   - `"pro"`
   - `"enterprise"`
3. **Targeting**:
   - If `plan` property equals `"pro"` → Return `"pro"` 
   - If `plan` property equals `"enterprise"` → Return `"enterprise"`
   - Otherwise return `"standard"`

## UI Implementation

Each view checks the feature flag and updates its interface based on the value:

1. **Dashboard**: Shows/hides pro and enterprise feature sections
2. **Typing View**: Adds character counting for pro, word counting for enterprise
3. **Tapping View**: Changes button size and adds statistics for higher plans
4. **Scrolling View**: Increases the number of items and adds badges for higher plans

Each view also uses a different color theme based on the plan level (blue for standard, purple for pro, green for enterprise).

## Challenges and Solutions

### Race Conditions

The primary challenge was race conditions between UI rendering and flag loading. We solved this by:

1. **Showing Loading States**: Displaying loading spinners during flag loading
2. **Explicit Timing Control**: Adding small delays to ensure flags are fully processed
3. **Independent Flag Checking**: Each view handles its own flag loading and checking
4. **Proper Dispatch Queue Usage**: Using async calls to avoid blocking the main thread

### Flag Reloading

Feature flag values are cached in the iOS SDK. When something changes with a user, flags need to be explicitly reloaded:

```swift
PostHogSDK.shared.reloadFeatureFlags()
```

We call this after login, after plan changes, and when views appear to ensure flag values are always current.

## Testing Strategy

Test the following scenarios to verify feature flag behavior:

1. **New User Login**: Should start with standard features
2. **Plan Upgrade**: Features should update immediately after purchase
3. **Re-login After Upgrade**: Feature level should persist between sessions
4. **Tab Switching**: Each tab should independently show the correct features
5. **Delayed Network**: App should show loading indicators until flags are loaded
