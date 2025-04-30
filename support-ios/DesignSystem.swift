import SwiftUI

/// Design system for the PostHog iOS Showcase app
/// Contains all shared design elements including colors, typography, spacing, and component styles
struct AppDesign {
    // MARK: - Colors
    struct Colors {
        // Brand colors
        static let primaryOrange = Color("PrimaryOrange") // PostHog orange
        static let secondaryBlue = Color("SecondaryBlue") // PostHog blue
        
        // Functional colors
        static let success = Color("Success")
        static let warning = Color("Warning")
        static let error = Color("Error")
        
        // UI colors
        static let background = Color("Background")
        static let card = Color("Card")
        static let text = Color("Text")
        static let textSecondary = Color("TextSecondary")
        static let border = Color("Border")
        
        // Plan colors (feature flag related)
        static let standard = Color("Standard") // Blue
        static let pro = Color("Pro") // Purple
        static let enterprise = Color("Enterprise") // Green
    }
    
    // MARK: - Typography
    struct Typography {
        // Font sizes
        static let smallSize: CGFloat = 14
        static let bodySize: CGFloat = 16
        static let titleSize: CGFloat = 22
        static let largeTitle: CGFloat = 28
        
        // Font weights
        static let regular = Font.Weight.regular
        static let medium = Font.Weight.medium
        static let bold = Font.Weight.bold
        
        // Text styles
        static let smallText = Font.system(size: smallSize, weight: regular)
        static let bodyText = Font.system(size: bodySize, weight: regular)
        static let titleText = Font.system(size: titleSize, weight: bold)
        static let largeTitleText = Font.system(size: largeTitle, weight: bold)
        
        // UI text styles
        static let caption = Font.system(size: smallSize, weight: regular)
        static let button = Font.system(size: bodySize, weight: medium)
        static let headline = Font.system(size: bodySize, weight: bold)
    }
    
    // MARK: - Spacing
    struct Spacing {
        static let tiny: CGFloat = 4
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
        static let extraLarge: CGFloat = 32
        static let huge: CGFloat = 48
    }
    
    // MARK: - Radius
    struct Radius {
        static let small: CGFloat = 4
        static let medium: CGFloat = 8
        static let large: CGFloat = 12
        static let extraLarge: CGFloat = 24
    }
    
    // MARK: - Shadows
    struct Shadows {
        static let small = Color.black.opacity(0.1)
        static let medium = Color.black.opacity(0.1)
        static let large = Color.black.opacity(0.15)
        
        static let smallRadius: CGFloat = 2
        static let mediumRadius: CGFloat = 4
        static let largeRadius: CGFloat = 8
    }
    
    // MARK: - Animation
    struct Animation {
        static let standard = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let slow = SwiftUI.Animation.easeInOut(duration: 0.5)
        static let quick = SwiftUI.Animation.easeInOut(duration: 0.2)
    }
}

// MARK: - Component Styles
extension AppDesign {
    /// Button styles for the app
    struct ButtonStyles {
        /// Primary action button style
        struct PrimaryButtonStyle: ButtonStyle {
            func makeBody(configuration: Configuration) -> some View {
                configuration.label
                    .font(AppDesign.Typography.button)
                    .padding(.horizontal, AppDesign.Spacing.large)
                    .padding(.vertical, AppDesign.Spacing.medium)
                    .background(AppDesign.Colors.primaryOrange)
                    .foregroundColor(.white)
                    .cornerRadius(AppDesign.Radius.medium)
                    .shadow(color: AppDesign.Shadows.small, radius: AppDesign.Shadows.smallRadius, x: 0, y: 1)
                    .scaleEffect(configuration.isPressed ? 0.98 : 1)
                    .animation(AppDesign.Animation.quick, value: configuration.isPressed)
            }
        }
        
        /// Secondary action button style
        struct SecondaryButtonStyle: ButtonStyle {
            func makeBody(configuration: Configuration) -> some View {
                configuration.label
                    .font(AppDesign.Typography.button)
                    .padding(.horizontal, AppDesign.Spacing.large)
                    .padding(.vertical, AppDesign.Spacing.medium)
                    .background(AppDesign.Colors.card)
                    .foregroundColor(AppDesign.Colors.primaryOrange)
                    .cornerRadius(AppDesign.Radius.medium)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppDesign.Radius.medium)
                            .stroke(AppDesign.Colors.primaryOrange, lineWidth: 1)
                    )
                    .shadow(color: AppDesign.Shadows.small, radius: AppDesign.Shadows.smallRadius, x: 0, y: 1)
                    .scaleEffect(configuration.isPressed ? 0.98 : 1)
                    .animation(AppDesign.Animation.quick, value: configuration.isPressed)
            }
        }
        
        /// Ghost/tertiary button style
        struct GhostButtonStyle: ButtonStyle {
            func makeBody(configuration: Configuration) -> some View {
                configuration.label
                    .font(AppDesign.Typography.button)
                    .foregroundColor(AppDesign.Colors.primaryOrange)
                    .padding(.horizontal, AppDesign.Spacing.medium)
                    .padding(.vertical, AppDesign.Spacing.small)
                    .scaleEffect(configuration.isPressed ? 0.98 : 1)
                    .animation(AppDesign.Animation.quick, value: configuration.isPressed)
            }
        }
    }
    
    /// Card styles for content containers
    struct CardStyle: ViewModifier {
        func body(content: Content) -> some View {
            content
                .padding(AppDesign.Spacing.large)
                .background(AppDesign.Colors.card)
                .cornerRadius(AppDesign.Radius.large)
                .shadow(color: AppDesign.Shadows.medium, radius: AppDesign.Shadows.mediumRadius, x: 0, y: 2)
        }
    }
    
    /// Feature section styles (for different plan levels)
    struct FeatureSectionStyle: ViewModifier {
        let planType: PlanType
        
        func body(content: Content) -> some View {
            content
                .padding(AppDesign.Spacing.medium)
                .background(Color.white)
                .cornerRadius(AppDesign.Radius.medium)
                .overlay(
                    RoundedRectangle(cornerRadius: AppDesign.Radius.medium)
                        .stroke(planType.color, lineWidth: 1)
                )
                .shadow(color: AppDesign.Shadows.small, radius: AppDesign.Shadows.smallRadius, x: 0, y: 1)
        }
    }
    
    /// Code snippet style for educational components
    struct CodeSnippetStyle: ViewModifier {
        func body(content: Content) -> some View {
            content
                .padding(AppDesign.Spacing.medium)
                .background(Color(.systemGray6))
                .cornerRadius(AppDesign.Radius.medium)
                .font(.system(.body, design: .monospaced))
        }
    }
    
    /// Educational tooltip style
    struct TooltipStyle: ViewModifier {
        func body(content: Content) -> some View {
            content
                .padding(AppDesign.Spacing.medium)
                .background(AppDesign.Colors.secondaryBlue.opacity(0.1))
                .cornerRadius(AppDesign.Radius.medium)
                .overlay(
                    RoundedRectangle(cornerRadius: AppDesign.Radius.medium)
                        .stroke(AppDesign.Colors.secondaryBlue, lineWidth: 1)
                )
                .shadow(color: AppDesign.Shadows.small, radius: AppDesign.Shadows.smallRadius, x: 0, y: 1)
        }
    }
}

// MARK: - View Extensions
extension View {
    func cardStyle() -> some View {
        modifier(AppDesign.CardStyle())
    }
    
    func featureSection(for planType: PlanType) -> some View {
        modifier(AppDesign.FeatureSectionStyle(planType: planType))
    }
    
    func codeSnippet() -> some View {
        modifier(AppDesign.CodeSnippetStyle())
    }
    
    func tooltip() -> some View {
        modifier(AppDesign.TooltipStyle())
    }
}

// MARK: - Button Extensions
extension View {
    func primaryButton() -> some View {
        buttonStyle(AppDesign.ButtonStyles.PrimaryButtonStyle())
    }
    
    func secondaryButton() -> some View {
        buttonStyle(AppDesign.ButtonStyles.SecondaryButtonStyle())
    }
    
    func ghostButton() -> some View {
        buttonStyle(AppDesign.ButtonStyles.GhostButtonStyle())
    }
} 