import Foundation

/// The living brain: a persistent "freshness" that DECAYS over time (loss
/// aversion → the daily pull) and RECOVERS when you engage (re-test, de-fry
/// tasks). Drives the avatar's burnt-ness. This is the Tamagotchi loop.
///
/// To make the decay *felt*, we remember where freshness was when you last saw
/// it (`freshnessBeforeDecay`) and how much this return cost you (`lastDecay`),
/// so the dashboard can animate the bar draining and show "you fried X% while
/// you were gone." A hidden loss can't drive behavior — it has to be seen.
@MainActor
final class BrainState: ObservableObject {
    @Published private(set) var freshness: Double = 58   // 0 = deep fried · 100 = crisp

    /// What freshness was when you last opened the app — the bar animates FROM
    /// here down to `freshness`, so you watch the overnight damage happen.
    @Published private(set) var freshnessBeforeDecay: Double = 58
    /// How much freshness this return cost you (0 if you just engaged).
    @Published private(set) var lastDecay: Double = 0
    /// Hours that elapsed to cause `lastDecay` — drives "while you were gone" copy.
    @Published private(set) var awayHours: Double = 0

    private let key = "fried.brain.freshness.v1"
    private let tsKey = "fried.brain.ts.v1"        // last decay checkpoint
    private let coolKey = "fried.brain.cool.v1"    // last time you actively cooled it
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
        cool(); save()
    }

    /// Completing a de-fry task cools your brain down (positive = recovery).
    func recover(_ amount: Double) {
        freshness = min(100, max(0, freshness + amount))
        if amount > 0 { cool() }
        save()
    }

    /// Hours since you last actively cooled it (test or de-fry task) — powers
    /// the live "still frying · last cooled Xh ago" readout.
    var hoursSinceCool: Double {
        let last = UserDefaults.standard.object(forKey: coolKey) as? Date ?? Date()
        return max(0, Date().timeIntervalSince(last) / 3600)
    }

    private func applyDecay() {
        freshnessBeforeDecay = freshness
        lastDecay = 0
        if let last = UserDefaults.standard.object(forKey: tsKey) as? Date {
            let interval = Date().timeIntervalSince(last)
            awayHours = max(0, interval / 3600)
            let days = interval / 86400
            if days > 0 {
                let target = max(0, freshness - days * decayPerDay)
                lastDecay = freshness - target
                freshness = target
            }
        }
        touch()
    }
    private func touch() { UserDefaults.standard.set(Date(), forKey: tsKey) }
    private func cool() { UserDefaults.standard.set(Date(), forKey: coolKey) }

    #if DEBUG
    /// Preview/testing only: fake a "returned after time away" state so the
    /// damage reveal can be demoed without actually waiting a day.
    func seedReturn(hoursAway: Double = 20) {
        let before = min(100, freshness + hoursAway / 24 * decayPerDay)
        freshnessBeforeDecay = before
        lastDecay = before - freshness
        awayHours = hoursAway
    }
    #endif
    private func save() {
        UserDefaults.standard.set(freshness, forKey: key)
        touch()
    }
}
