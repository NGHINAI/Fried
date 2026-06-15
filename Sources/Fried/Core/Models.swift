import Foundation

/// The five tiers, mapped from a 0–100 Fried Score. Order = increasing "fried-ness".
/// NOTE: branded, subjective vibe-check labels only — never a cognitive/health claim.
enum FriedTier: String, CaseIterable, Equatable {
    case crispMind
    case lightlyToasted
    case wellDone
    case extraCrispy
    case deepFried

    init(score: Int) {
        switch score {
        case ..<25: self = .crispMind
        case ..<50: self = .lightlyToasted
        case ..<75: self = .wellDone
        case ..<90: self = .extraCrispy
        default:    self = .deepFried
        }
    }

    var title: String {
        switch self {
        case .crispMind:      return "Crisp Mind"
        case .lightlyToasted: return "Lightly Toasted"
        case .wellDone:       return "Well Done"
        case .extraCrispy:    return "Extra Crispy"
        case .deepFried:      return "Deep Fried"
        }
    }

    var emoji: String {
        switch self {
        case .crispMind:      return "🧠"
        case .lightlyToasted: return "🍞"
        case .wellDone:       return "🔥"
        case .extraCrispy:    return "💀"
        case .deepFried:      return "☠️"
        }
    }
}

/// Self-reported quiz answers. `answerIndices[i]` in 0...maxIndex (0 = least fried).
struct QuizResult: Equatable {
    let answerIndices: [Int]
    let maxIndex: Int
}

/// Output of the in-app reaction mini-game (a playful "vibe" proxy, not a test).
/// - meanMillis: average reaction time.
/// - lapseVariance: normalized erraticness 0...1+ (higher = more inconsistent).
struct ReactionResult: Equatable {
    let meanMillis: Double
    let lapseVariance: Double
}

struct AppUsage: Equatable {
    let app: String
    let minutes: Int
}

/// Parsed from an optional Screen Time screenshot (OCR). Not required for the core score.
struct ScreenTimeResult: Equatable {
    let totalMinutes: Int
    let apps: [AppUsage]
}

/// The final result shown on the reveal screen.
struct FriedScore: Equatable {
    let value: Int        // 0...100
    let tier: FriedTier
}
