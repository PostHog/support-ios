# Support iOS App

This is a SwiftUI iOS app used for testing PostHog features and demonstrating best practices for iOS implementation.

## Implemented PostHog Features

- ✅ **Autocapture** - Automatically tracks button taps, text field interactions, and scrolling
- ✅ **Session Replay** - Records user sessions with screenshot mode for SwiftUI compatibility
- ✅ **Custom Events** - Various examples of custom event tracking with properties
- ✅ **Screen Tracking** - Manual screen view tracking in the TabView
- ✅ **Feature Flags** - Multiple flag types (boolean, string) with proper fallbacks
- ✅ **User Identification** - User properties and plan-based segmentation
- ✅ **Event Properties** - Contextual data sent with events to provide richer analytics
- ✅ **Optimized Flag Reloading** - Centralized feature flag management for performance

## Demo Views

- **Home/Login View** - Test login flow and user identification
- **Feature Explorer** - Browse available PostHog features based on plan tier
- **TypingView** - Capture text input events and test autocapture on text fields
- **TappingView** - Track button taps and test custom events with properties
- **ScrollingView** - Test scroll event capture and session replay recordings
- **Feature Flags Demo** - See feature flags in action with different flag types

## Setup

1. Clone the repo
2. Open `support-ios.xcodeproj` in Xcode
3. Replace the placeholder PostHog API key with yours in `support_iosApp.swift`
4. Run in Simulator or on a physical device

## PostHog Integration

PostHog is set up in `support_iosApp.swift` via SwiftUI with this configuration:

```swift
let config = PostHogConfig(apiKey: "phc_...", host: "https://us.i.posthog.com")
config.captureApplicationLifecycleEvents = true  // Track app open/close
config.captureScreenViews = false                // Using manual screen tracking
config.captureElementInteractions = true         // Enable autocapture
config.sessionReplay = true                      // Enable session recording
config.sessionReplayConfig.screenshotMode = true // Required for SwiftUI
config.flushAt = 1                               // Flush events immediately (for testing)
config.debug = true                              // Enable debug logging
config.preloadFeatureFlags = true                // Load flags at startup
PostHogSDK.shared.setup(config)
```

## Testing Guide

### User Identification
1. Start the app and go through the onboarding flow
2. Use the login form to identify as different users
3. Check in PostHog that distinct users are being tracked

### Event Tracking
1. Navigate to the TappingView tab
2. Tap the circle button multiple times
3. Try the "Send Event" feature on the login screen with custom event names
4. Check the PostHog dashboard to see these events with their properties

### Session Replay
1. Navigate through different tabs
2. Interact with various elements (buttons, text fields, scrolling)
3. Check the Session Replay section in PostHog to see your recorded session

### Feature Flags
1. Create feature flags in PostHog with these keys:
   - `plan-features` (string: "standard", "pro", "enterprise")
   - `ios-feature-a` (boolean)
   - `ios-feature-b` (boolean)
   - `ios-text-color` (string: "blue", "green", "purple", "default")
   - `ios-button-style` (string: "standard", "rounded", "shadowed")
2. Navigate to the Feature Flags demo in the Features tab
3. Target flags to different users based on properties or percentages
4. Change the plan in the app to see feature access change

### Testing Plan-based Features
1. Use the "Change Plan" button to switch between Standard, Pro, and Enterprise
2. Notice how available features and UI elements change based on the plan
3. This demonstrates targeting feature flags based on user properties

## Best Practices Demonstrated

1. **Proper SDK Initialization** - PostHog is initialized early with appropriate settings
2. **Feature Flag Fallbacks** - All feature flag checks include fallbacks
3. **Contextual Properties** - Events include relevant properties for better analytics
4. **Manual Screen Tracking** - Properly tracks screens despite SwiftUI's limitations
5. **Session Replay Configuration** - Uses screenshot mode for SwiftUI compatibility
6. **User Property Targeting** - Shows how to use plan-based targeting for features
7. **Clean Lifecycle Management** - Proper user reset on logout
8. **Optimized Flag Reloading** - Only reloads flags when user properties change (login, plan changes)

## Feature Flag Optimization

For optimal performance, the app uses a centralized approach to feature flag management:

1. **When to reload flags** - Only reloads feature flags when critical user properties change:
   - After user login
   - After plan changes
   
2. **Centralized reloading** - Uses a dedicated `FeatureFlagManager` class to handle reloading:
   ```swift
   FeatureFlagManager.reloadFeatureFlags {
       // Code to run after flags are loaded
   }
   ```

3. **Simple flag reading** - All UI components simply read the current flag values without reloading:
   ```swift
   if let planFeatures = PostHogSDK.shared.getFeatureFlag("plan-features") as? String {
       // Apply UI changes based on the flag value
   }
   ```
   
This approach ensures that flags are always up-to-date while minimizing unnecessary network requests.