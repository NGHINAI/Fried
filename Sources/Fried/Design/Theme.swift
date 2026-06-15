import SwiftUI

/// Single source of truth for the Fried look: dark premium "Liquid Glass" + a
/// "fried" heat gradient (amber → hot red), SF Pro Rounded, generous spacing.
enum Theme {
    // Canvas
    static let canvas = Color(red: 0.039, green: 0.039, blue: 0.043)
    static let canvasElevated = Color(red: 0.08, green: 0.08, blue: 0.09)

    // Text
    static let textPrimary = Color(red: 0.96, green: 0.96, blue: 0.97)
    static let textSecondary = Color(red: 0.60, green: 0.60, blue: 0.64)

    // Heat accent (the brand)
    static let heatTop = Color(red: 1.0, green: 0.69, blue: 0.13)    // amber
    static let heatMid = Color(red: 1.0, green: 0.42, blue: 0.17)    // orange
    static let heatBottom = Color(red: 1.0, green: 0.23, blue: 0.18) // hot red
    static let mint = Color(red: 0.22, green: 0.90, blue: 0.78)      // cool counter-accent

    static let heatGradient = LinearGradient(
        colors: [heatTop, heatMid, heatBottom], startPoint: .top, endPoint: .bottom)
    static let heatGradientH = LinearGradient(
        colors: [heatTop, heatBottom], startPoint: .leading, endPoint: .trailing)

    static func color(for tier: FriedTier) -> Color {
        switch tier {
        case .crispMind:      return mint
        case .lightlyToasted: return heatTop
        case .wellDone:       return heatMid
        case .extraCrispy:    return heatBottom
        case .deepFried:      return Color(red: 1.0, green: 0.13, blue: 0.10)
        }
    }

    static func gradient(for tier: FriedTier) -> LinearGradient {
        switch tier {
        case .crispMind:
            return LinearGradient(colors: [mint, Color(red: 0.13, green: 0.70, blue: 0.86)],
                                  startPoint: .top, endPoint: .bottom)
        case .lightlyToasted:
            return LinearGradient(colors: [heatTop, heatMid], startPoint: .top, endPoint: .bottom)
        default:
            return heatGradient
        }
    }

    // Spacing & shape
    static let pad: CGFloat = 20
    static let radius: CGFloat = 26

    // Fonts (SF Pro Rounded throughout)
    static func score(_ size: CGFloat) -> Font { .system(size: size, weight: .heavy, design: .rounded) }
    static func title(_ size: CGFloat = 30) -> Font { .system(size: size, weight: .bold, design: .rounded) }
    static func body(_ size: CGFloat = 17) -> Font { .system(size: size, weight: .medium, design: .rounded) }
    static func label(_ size: CGFloat = 14) -> Font { .system(size: size, weight: .semibold, design: .rounded) }
}
