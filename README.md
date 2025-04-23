# Support iOS App

This is a SwiftUI iOS app used for testing PostHog features.

Currently includes:

- ✅ Autocapture (buttons, fields, scrolling)
- ✅ Session Replay
- ✅ Custom Events
- ✅ Screen tracking via TabView

## Features

- 3 demo views:
  - **TypingView** — capture text input
  - **TappingView** — track button taps and custom events
  - **ScrollingView** — test scroll event capture
- PostHog SDK initialized in `support_iosApp.swift`

## Setup

1. Clone the repo
2. Open `support-ios.xcodeproj` in Xcode
3. Replace the placeholder PostHog API key with yours
4. Run in Simulator

## PostHog Integration

PostHog is set up in `support_iosApp.swift` via SwiftUI:

```swift
let config = PostHogConfig(apiKey: "phc_...", host: "https://us.i.posthog.com")
config.sessionReplay = true
PostHogSDK.shared.setup(config)
```