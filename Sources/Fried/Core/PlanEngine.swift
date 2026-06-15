import Foundation

/// The real value behind the paywall: a personalized "de-fry plan" derived from
/// the user's actual quiz answers + reaction data — a focus reset, not just a number.
struct DefryPlan {
    let diagnosis: String
    let leaks: [String]      // the specific things hurting them
    let steps: [String]      // concrete, tailored actions
    let challenge: String    // a 7-day goal
}

enum PlanEngine {
    /// (leak, step) for each quiz question when answered toward the "fried" end.
    private static let map: [(leak: String, step: String)] = [
        ("Short-form video is eating your day",   "Set a 20-minute daily limit on TikTok / Reels / Shorts."),
        ("Your phone hijacks your downtime",      "Leave your phone in another room during shows and meals."),
        ("Too many open loops at once",           "One tab, one task — close the rest before you start."),
        ("The morning scroll sets a fried tone",  "No phone for the first 30 minutes after you wake up."),
        ("You start more than you finish",        "Work in 25-minute focus blocks with your phone face-down."),
        ("Your go-to app is a slot machine",      "Greyscale it, or move it off your home screen.")
    ]

    static func plan(score: FriedScore, quiz: QuizResult?, reaction: ReactionResult?) -> DefryPlan {
        // Pick the worst answers as the user's biggest leaks.
        var ranked: [(idx: Int, weight: Int)] = []
        if let q = quiz {
            for (i, a) in q.answerIndices.enumerated() where i < map.count && a >= 2 {
                ranked.append((i, a))
            }
        }
        ranked.sort { $0.weight > $1.weight }
        var leaks = ranked.prefix(3).map { map[$0.idx].leak }
        var steps = ranked.prefix(3).map { map[$0.idx].step }

        // Reaction-based step.
        if let r = reaction, r.meanMillis > 360 {
            steps.append("Train your focus: a 2-minute no-distraction reset before deep work.")
        }
        // Always give them at least 3 steps.
        if steps.isEmpty {
            leaks = ["You're mostly in control — but the feed is always pulling."]
            steps = ["Keep one phone-free hour a day.",
                     "Greyscale your phone after 9pm.",
                     "Take the test daily to hold the line."]
        }

        return DefryPlan(
            diagnosis: diagnosis(for: score.tier),
            leaks: Array(leaks),
            steps: Array(steps.prefix(4)),
            challenge: challenge(for: score)
        )
    }

    private static func diagnosis(for tier: FriedTier) -> String {
        switch tier {
        case .crispMind:      return "You're genuinely locked in. This plan keeps you there."
        case .lightlyToasted: return "A few soft spots are letting the feed in. Easy to seal up."
        case .wellDone:       return "The feed has a real grip on you — but every bit of this is reversible."
        case .extraCrispy:    return "You're deep in algorithm territory. This plan pulls you back out."
        case .deepFried:      return "Fully fried — so there's nowhere to go but up. Start with step one."
        }
    }

    private static func challenge(for score: FriedScore) -> String {
        let target = max(5, min(20, score.value / 4 + 5))
        return "Your 7-day challenge: take the test daily and drop your score by \(target). Keep the streak alive."
    }
}
