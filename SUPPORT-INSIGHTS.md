# iOS Support Insights

## Flushing Analytics Events

**Flushing** is a performance optimization used by mobile analytics SDKs to batch events before sending them to the server, reducing battery and network usage. However, events can be lost if the app crashes or is backgrounded before a flush occurs. It's recommended to manually call flush() after critical actions like `identify()`, logouts, or conversions to ensure important events are sent immediately.

By default, PostHog’s iOS SDK:
```swift
config.flushAt = 20 // Flushes after 20 events
```

This works well for most general use cases. However:

- Setting flushAt = 1 sends events immediately (⚠️ not recommended in production).
- Manual flushing is possible using:

```swift
PostHogSDK.shared.capture("important_event")
PostHogSDK.shared.flush()
```