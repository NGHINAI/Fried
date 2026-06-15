import Foundation

/// Pure, deterministic scoring. NO AI involved — the score is honest math.
/// Blends a self-report quiz axis, a reaction-game axis, and (optionally) a
/// screen-time axis into a single 0–100 Fried Score.
enum ScoringEngine {

    static func score(quiz: QuizResult,
                      reaction: ReactionResult,
                      screenTime: ScreenTimeResult?) -> FriedScore {
        let quizAxis = quizScore(quiz)            // 0...100
        let reactionAxis = reactionScore(reaction) // 0...100

        let total: Double
        if let st = screenTime {
            let screenAxis = screenScore(st)       // 0...100
            total = 0.45 * quizAxis + 0.45 * reactionAxis + 0.10 * screenAxis
        } else {
            // Redistribute the screen weight equally when absent.
            total = 0.50 * quizAxis + 0.50 * reactionAxis
        }

        let clamped = Int(max(0, min(100, total.rounded())))
        return FriedScore(value: clamped, tier: FriedTier(score: clamped))
    }

    /// Fraction of the maximum possible "fried" answers, as 0...100.
    static func quizScore(_ q: QuizResult) -> Double {
        guard !q.answerIndices.isEmpty, q.maxIndex > 0 else { return 0 }
        let sum = q.answerIndices.reduce(0, +)
        let maxSum = q.maxIndex * q.answerIndices.count
        return Double(sum) / Double(maxSum) * 100
    }

    /// Slower + more erratic reactions ⇒ more fried. Mean 200–650ms maps to 0–100.
    static func reactionScore(_ r: ReactionResult) -> Double {
        let rtComponent = (r.meanMillis - 200) / (650 - 200) * 100
        let lapseComponent = r.lapseVariance * 100
        let blended = 0.7 * rtComponent + 0.3 * lapseComponent
        return max(0, min(100, blended))
    }

    /// 0–10h/day of screen time maps to 0–100.
    static func screenScore(_ s: ScreenTimeResult) -> Double {
        max(0, min(100, Double(s.totalMinutes) / 600 * 100))
    }
}
