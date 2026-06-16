import SwiftUI

/// Refined, premium aesthetic (Reticla-inspired): neutral near-black surfaces,
/// elegant light-weight SF Pro typography, a single muted-copper accent used
/// sparingly, dark subtle glass, generous negative space.
enum Theme {
    // Surfaces — neutral near-black
    static let void     = Color(red: 0.039, green: 0.039, blue: 0.047) // #0A0A0C
    static let canvas   = Color(red: 0.059, green: 0.059, blue: 0.067) // #0F0F11
    static let surface1 = Color(red: 0.086, green: 0.086, blue: 0.098) // #161619
    static let surface2 = Color(red: 0.118, green: 0.118, blue: 0.133) // #1E1E22
    static let hairline = Color.white.opacity(0.10)

    // Text — refined off-white + muted gray
    static let textPrimary   = Color(red: 0.929, green: 0.929, blue: 0.945) // #EDEDF1
    static let textSecondary = Color(red: 0.560, green: 0.560, blue: 0.600) // #8F8F99

    // Accent — muted copper (premium, used sparingly)
    static let amber    = Color(red: 0.851, green: 0.549, blue: 0.361) // #D98C5C primary
    static let ember    = Color(red: 0.761, green: 0.420, blue: 0.290) // #C26B4A
    static let deepHeat = Color(red: 0.620, green: 0.310, blue: 0.212) // #9E4F36
    static let glow     = Color(red: 0.902, green: 0.627, blue: 0.455) // #E6A074 (light only)
    static let mint     = Color(red: 0.435, green: 0.749, blue: 0.690) // #6FBFB0 muted teal
    static let goGreen  = Color(red: 0.40, green: 0.78, blue: 0.58)

    // Semantic state — red signals DECLINE / LOSS only (used sparingly = stays urgent)
    static let danger   = Color(red: 0.898, green: 0.337, blue: 0.310) // #E5564F desaturated alarm
    static let recovery = goGreen                                       // gains / the way out

    // Back-compat aliases
    static var heatTop: Color { amber }
    static var heatMid: Color { ember }
    static var heatBottom: Color { deepHeat }

    static let heatGradient  = LinearGradient(colors: [glow, amber, ember], startPoint: .top, endPoint: .bottom)
    static let heatGradientH = LinearGradient(colors: [amber, ember], startPoint: .leading, endPoint: .trailing)

    static func color(for tier: FriedTier) -> Color {
        switch tier {
        case .crispMind:      return mint
        case .lightlyToasted: return glow
        case .wellDone:       return amber
        case .extraCrispy:    return ember
        case .deepFried:      return deepHeat
        }
    }
    static func gradient(for tier: FriedTier) -> LinearGradient {
        switch tier {
        case .crispMind:
            return LinearGradient(colors: [mint, Color(red: 0.30, green: 0.62, blue: 0.66)], startPoint: .top, endPoint: .bottom)
        case .lightlyToasted:
            return LinearGradient(colors: [glow, amber], startPoint: .top, endPoint: .bottom)
        case .wellDone:
            return LinearGradient(colors: [amber, ember], startPoint: .top, endPoint: .bottom)
        default:
            return LinearGradient(colors: [amber, ember, deepHeat], startPoint: .top, endPoint: .bottom)
        }
    }
    static func glowColor(for tier: FriedTier) -> Color {
        tier == .crispMind ? mint : glow
    }

    // Spacing & shape
    static let pad: CGFloat = 22
    static let radius: CGFloat = 22

    // Type — refined SF Pro (NOT rounded), lighter weights, generous.
    // Numerals are TABULAR (monospacedDigit) so a score reads as a measured
    // instrument value, not a designed graphic — credibility = the insecurity bites.
    static func display(_ s: CGFloat) -> Font { .system(size: s, weight: .regular, design: .default) }
    static func score(_ s: CGFloat) -> Font { .system(size: s, weight: .medium, design: .default).monospacedDigit() }
    /// The enormous verdict number on the reveal — heavy, tabular, tight.
    static func hero(_ s: CGFloat) -> Font { .system(size: s, weight: .bold, design: .default).monospacedDigit() }
    static func title(_ s: CGFloat = 28) -> Font { .system(size: s, weight: .semibold, design: .default) }
    static func body(_ s: CGFloat = 17) -> Font { .system(size: s, weight: .regular, design: .default) }
    static func label(_ s: CGFloat = 13) -> Font { .system(size: s, weight: .medium, design: .default) }
}
