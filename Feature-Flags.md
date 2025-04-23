# Step-by-Step Testing Guide for PostHog Feature Flags

## Initial Setup

1. **Launch the app** for the first time
2. You should be in "Logged Out Mode"

## Test Case 1: Standard User Journey

1. **Log in** with username "standard_user" (password doesn't matter)
2. You should be directed to the dashboard
3. **Verify initial state**:
   - Only "Standard Features" section should be visible
   - Dashboard header should show "Current Plan: Standard" in blue
4. **Click "Change Plan"** at the top right
5. **Select the Pro plan** by tapping on it
6. **Click "Purchase Pro Plan"** button
7. **Confirm the purchase** in the alert dialog
8. **Observe the response**:
   - If "show-upgrade-modal" feature flag is enabled for pro users, a modal should appear
   - Click "Continue to Dashboard" on the modal
9. **Verify dashboard updates**:
   - "Pro Features" section should now be visible if "show-pro-features" flag is enabled
   - Dashboard header might change color if "dashboard-color" flag is set differently for pro users

## Test Case 2: Enterprise Features

1. While logged in, **click "Change Plan"** again
2. **Select the Enterprise plan**
3. **Click "Purchase Enterprise Plan"** and confirm
4. **Verify dashboard updates**:
   - "Enterprise Features" section should appear if "show-enterprise-features" flag is enabled
   - Dashboard header might change color again if "dashboard-color" is set differently for enterprise users

## Test Case 3: Feature Flag Consistency

1. **Log out** using the "Logout" button at the bottom
2. **Log in again** with the same username you last used
3. **Verify persistence**:
   - Dashboard should immediately show the correct features based on your last plan
   - The upgrade modal should not appear again (it's only for the upgrade flow)

## Test Case 4: Multiple Users with Different Plans

1. **Log out** again
2. **Log in** with username "pro_user"
3. **Verify** that Pro features appear immediately (since the identify call sets "plan" to "pro")
4. **Log out** and **log in** with username "enterprise_user"
5. **Verify** that both Pro and Enterprise features appear (since the plan is "enterprise")

## Test Case 5: Feature Flag Reload Testing

1. While logged in, go to one of the other tabs (Typing, Tapping, or Scrolling)
2. Change some of the feature flag settings in PostHog dashboard:
   - Change the targeting rules or rollout percentages
   - Save the changes
3. **Return to the Dashboard tab**
4. The features shown may still reflect the old flags since they're cached
5. **Pull down to refresh** the dashboard (or add a refresh button if needed)
6. **Verify** the dashboard updates according to the new flag values

## Test Case 6: Flag Value Types

1. In PostHog, change the "dashboard-color" flag to return different values:
   - Try "red" for one user segment
   - Try "green" for another
2. **Log in** with usernames that match these segments
3. **Verify** the dashboard header color updates according to the flag value

## Edge Case Testing

1. **Test with network issues**:
   - Put device in airplane mode
   - Log out and back in
   - Verify the app handles offline flag evaluation gracefully (should use cached values)

2. **Test rapid plan changes**:
   - Change plans multiple times in quick succession 
   - Verify the feature flags update correctly after each change

3. **Test feature flag polling**:
   - Log in and keep the app open for >30 seconds
   - Change flag values in PostHog
   - Wait for the polling interval to complete
   - Verify updates occur without requiring app restart

This testing plan covers the core functionality of your feature flag implementation and verifies that it behaves consistently across different user states and scenarios.
