import Foundation

/// "Brain Age" — a playful focus-age derived from the test + brain state. When
/// you're fried it runs OLDER than your real age (the insecurity hook); sharp,
/// and it runs younger. Entertainment only — not a real cognitive measure.
enum BrainAgeEngine {
    static func brainAge(realAge: Int, score: FriedScore, reaction: ReactionResult?, freshness: Double) -> Int {
        let scoreComp = Double(score.value) / 100.0
        let freshComp = max(0, min(1, (100 - freshness) / 100.0))
        let reactComp = reaction.map { min(1, max(0, ($0.meanMillis - 220) / 380)) } ?? scoreComp
        let deficit = scoreComp * 0.40 + freshComp * 0.25 + reactComp * 0.35
        let drift = Int((deficit * 26 - 6).rounded())   // −6 (sharp) … +20 (fried)
        return max(13, min(99, realAge + drift))
    }

    /// "17 years older than you should be" style line.
    static func gapLine(realAge: Int, brainAge: Int) -> String {
        let gap = brainAge - realAge
        if gap >= 6  { return "\(gap) years older than you actually are." }
        if gap >= 1  { return "A touch older than your real age." }
        if gap == 0  { return "Right on your real age." }
        return "\(abs(gap)) years younger than your real age. Sharp."
    }
}
