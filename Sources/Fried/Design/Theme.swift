import SwiftUI

/// Single source of truth. Premium "fried" look: warm near-black surfaces,
/// ONE disciplined amber accent (desaturated for dark so it glows, not screams),
/// ambient heat-glow behind frosted glass. Never pure black behind text.
enum Theme {
    // Surfaces — warm near-black, layered for elevation
    static let void     = Color(red: 0.039, green: 0.031, blue: 0.027) // #0A0807 (behind glass)
    static let canvas   = Color(red: 0.063, green: 0.047, blue: 0.039) // #100C0A
    static let surface1 = Color(red: 0.094, green: 0.075, blue: 0.067) // #181311
    static let surface2 = Color(red: 0.129, green: 0.098, blue: 0.082) // #211915
    static let hairline = Color(red: 1.0, green: 0.94, blue: 0.90).opacity(0.12)

    // Text — warm off-white (avoids halation)
    static let textPrimary   = Color(red: 0.949, green: 0.929, blue: 0.914) // #F2EDE9
    static let textSecondary = Color(red: 0.949, green: 0.929, blue: 0.914).opacity(0.62)

    // Heat accent system (slightly desaturated for dark)
    static let amber    = Color(red: 0.961, green: 0.647, blue: 0.141) // #F5A524 — PRIMARY
    static let ember    = Color(red: 0.886, green: 0.376, blue: 0.165) // #E2602A
    static let deepHeat = Color(red: 0.698, green: 0.227, blue: 0.118) // #B23A1E
    static let glow     = Color(red: 1.0, green: 0.722, blue: 0.302)   // #FFB84D — light only
    static let mint     = Color(red: 0.35, green: 0.85, blue: 0.74)    // refined cool tier accent
    static let goGreen  = Color(red: 0.20, green: 0.85, blue: 0.52)    // reaction "TAP!" state

    // Back-compat aliases
    static var heatTop: Color { amber }
    static var heatMid: Color { ember }
    static var heatBottom: Color { deepHeat }

    static let heatGradient  = LinearGradient(colors: [amber, ember, deepHeat], startPoint: .top, endPoint: .bottom)
    static let heatGradientH = LinearGradient(colors: [amber, ember], startPoint: .leading, endPoint: .trailing)

    static func color(for tier: FriedTier) -> Color {
        switch tier {
        case .crispMind:      return mint
        case .lightlyToasted: return amber
        case .wellDone:       return ember
        case .extraCrispy:    return deepHeat
        case .deepFried:      return Color(red: 0.85, green: 0.20, blue: 0.10)
        }
    }
    static func gradient(for tier: FriedTier) -> LinearGradient {
        switch tier {
        case .crispMind:
            return LinearGradient(colors: [mint, Color(red: 0.18, green: 0.65, blue: 0.80)],
                                  startPoint: .top, endPoint: .bottom)
        case .lightlyToasted:
            return LinearGradient(colors: [glow, amber], startPoint: .top, endPoint: .bottom)
        case .wellDone:
            return LinearGradient(colors: [amber, ember], startPoint: .top, endPoint: .bottom)
        default:
            return heatGradient
        }
    }
    static func glowColor(for tier: FriedTier) -> Color {
        tier == .crispMind ? mint : glow
    }

    // Spacing & shape
    static let pad: CGFloat = 20
    static let radius: CGFloat = 24

    // Type (SF Pro Rounded)
    static func score(_ s: CGFloat) -> Font { .system(size: s, weight: .heavy, design: .rounded) }
    static func title(_ s: CGFloat = 30) -> Font { .system(size: s, weight: .bold, design: .rounded) }
    static func body(_ s: CGFloat = 17) -> Font { .system(size: s, weight: .medium, design: .rounded) }
    static func label(_ s: CGFloat = 14) -> Font { .system(size: s, weight: .semibold, design: .rounded) }
}
