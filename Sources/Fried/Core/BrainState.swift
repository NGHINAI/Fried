import Foundation

/// The living brain: a persistent "freshness" that DECAYS over time (loss
/// aversion → the daily pull) and RECOVERS when you engage (re-test, de-fry
/// tasks). Drives the avatar's burnt-ness. This is the Tamagotchi loop.
@MainActor
final class BrainState: ObservableObject {
    @Published private(set) var freshness: Double = 58   // 0 = deep fried · 100 = crisp

    private let key = "fried.brain.freshness.v1"
    private let tsKey = "fried.brain.ts.v1"
    private let decayPerDay = 13.0

    init() {
        if let v = UserDefaults.standard.object(forKey: key) as? Double { freshness = v }
        applyDecay()
    }

    /// 0 (fresh) … 1 (burnt) — what the avatar renders.
    var friedLevel: Double { (100 - freshness) / 100 }
    var friedPercent: Int { Int((100 - freshness).rounded()) }

    var label: String {
        switch freshness {
        case 75...:     return "Crisp"
        case 50..<75:   return "Toasting"
        case 25..<50:   return "Frying"
        default:        return "Burnt"
        }
    }

    /// Taking the test measures your brain — set state from today's score,
    /// blended slightly with where you were (so it feels persistent).
    func registerScore(_ friedScore: Int) {
        let measured = Double(100 - friedScore)
        freshness = freshness * 0.25 + measured * 0.75
        save()
    }

    /// Completing a de-fry task cools your brain down.
    func recover(_ amount: Double) {
        freshness = min(100, freshness + amount)
        save()
    }

    /// Hours since you last cooled it down — used for "frying again" urgency.
    var hoursSinceTouch: Double {
        let last = UserDefaults.standard.object(forKey: tsKey) as? Date ?? Date()
        return max(0, Date().timeIntervalSince(last) / 3600)
    }

    private func applyDecay() {
        let last = UserDefaults.standard.object(forKey: tsKey) as? Date
        if let last {
            let days = Date().timeIntervalSince(last) / 86400
            if days > 0 { freshness = max(0, freshness - days * decayPerDay) }
        }
        touch()
    }
    private func touch() { UserDefaults.standard.set(Date(), forKey: tsKey) }
    private func save() {
        UserDefaults.standard.set(freshness, forKey: key)
        touch()
    }
}
