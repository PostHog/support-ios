# iOS Support Insights

## Flushing Analytics Events

**Flushing** is a performance optimization used by mobile analytics SDKs to batch events before sending them to the server, reducing battery and network usage. However, events can be lost if the app crashes or is backgrounded before a flush occurs. It's recommended to manually call `flush()` after critical actions like `identify()`, logouts, or conversions to ensure important events are sent immediately.

By default, PostHog's iOS SDK:
```swift
config.flushAt = 20 // Flushes after 20 events
```

This works well for most general use cases. However:

- Setting `flushAt = 1` sends events immediately (⚠️ not recommended in production).
- Manual flushing is possible using:

```swift
PostHogSDK.shared.capture("important_event")
PostHogSDK.shared.flush()
``` 

## Feature Flag Loading Challenges

**Feature flags** in iOS SDKs load asynchronously, which can cause race conditions where the UI renders before flag values are available. This leads to flickering or incorrect initial states as flags load.

Key solutions to mitigate these issues:

```swift
// APPROACH 1: Add loading states
@State private var isLoading = true

// In view body
if isLoading {
    ProgressView("Loading...")
} else {
    // Feature-dependent content
}

// APPROACH 2: Add delay after reloading
PostHogSDK.shared.reloadFeatureFlags()
DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
    // Check flag values
    let flagValue = PostHogSDK.shared.getFeatureFlag("my-flag")
    // Update UI
    isLoading = false
}
```

Best practices to ensure consistent feature flag behavior:
- Must reload feature flags with `PostHogSDK.shared.reloadFeatureFlags()` when something changes about the user that would change the flag value, otherwise it uses cached values
- Add loading indicators while flags load
- Explicitly reload flags after login/property changes
- Add small delays (0.3-0.5s) before checking flag values
- Independently manage flag loading in each view
- Use a fallback in case feature flags fail