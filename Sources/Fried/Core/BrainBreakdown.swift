import Foundation

/// One axis of the strict brain breakdown. `fried` is 0…100 (higher = worse) and
/// is traceable to specific inputs — that's what makes the headline number feel
/// EARNED rather than random, and the five axes are the core of what the paywall
/// unlocks ("you know THAT you're fried; pay to see WHY and HOW to fix it").
struct BrainDimension: Identifiable, Equatable {
    let key: String       // short uppercase tag, e.g. "ATTENTION"
    let label: String     // human label
    let fried: Int        // 0…100, higher = more fried
    let blurb: String     // one honest, second-person line naming the signal (paid)
    var id: String { key }
}

/// The full strict assessment behind one tap: the headline score, the five
/// contributing axes, where the user sits vs others (social comparison), and the
/// recoverable gap (loss framing). Deterministic — no AI, honest math.
struct BrainBreakdown: Equatable {
    let overall: Int                 // headline fried score (0…100)
    let dimensions: [BrainDimension]
    let percentile: Int              // "more fried than X% of people your age"
    let potential: Int               // recoverable target fried-level (lower = better)

    /// Points you could claw back with the plan — the loss you're sitting on.
    var gap: Int { max(0, overall - potential) }
    /// The #1 thing frying you (the named leak the paywall teases).
    var topLeak: BrainDimension { dimensions.max(by: { $0.fried < $1.fried }) ?? dimensions[0] }
    var strongest: BrainDimension { dimensions.min(by: { $0.fried < $1.fried }) ?? dimensions[0] }
}

enum BrainBreakdownEngine {
    /// Map a 0…maxIndex quiz answer to 0…100. Missing → neutral 50.
    private static func q(_ idx: Int, _ a: [Int], _ m: Int) -> Double {
        guard idx < a.count, m > 0 else { return 50 }
        return Double(a[idx]) / Double(m) * 100
    }
    private static func avg(_ xs: [Double]) -> Double { xs.isEmpty ? 0 : xs.reduce(0, +) / Double(xs.count) }
    private static func clampInt(_ x: Double) -> Int { Int(max(0, min(100, x.rounded()))) }

    /// `overall` is the canonical Fried Score (from ScoringEngine) so the breakdown
    /// always decomposes the same number the user sees.
    static func make(quiz: QuizResult?, reaction: ReactionResult?,
                     screenTime: ScreenTimeResult?, overall: Int, age: Int) -> BrainBreakdown {
        let a = quiz?.answerIndices ?? []
        let m = quiz?.maxIndex ?? QuizContent.maxIndex
        let st = screenTime.map { min(100, Double($0.totalMinutes) / 600 * 100) }   // 0…100

        // 1 · Attention span ← movie-without-phone (Q1), tabs (Q2), finishing (Q4), reaction steadiness
        var attention = avg([q(1, a, m), q(2, a, m), q(4, a, m)])
        if let r = reaction { attention = attention * 0.75 + min(100, r.lapseVariance * 100) * 0.25 }
        // 2 · Dopamine load ← short-form (Q0), poison (Q5) (+ screen time)
        var dopamine = avg([q(0, a, m), q(5, a, m)])
        if let s = st { dopamine = dopamine * 0.8 + s * 0.2 }
        // 3 · Sleep & mornings ← morning phone (Q3) (+ screen-time load)
        var sleep = q(3, a, m)
        if let s = st { sleep = sleep * 0.8 + s * 0.2 }
        // 4 · Reflex speed ← reaction mean RT (200→650ms maps to 0→100)
        let reflexes = reaction.map { max(0, min(100, ($0.meanMillis - 200) / (650 - 200) * 100)) } ?? Double(overall)
        // 5 · Focus consistency ← reaction erraticness
        let consistency = reaction.map { min(100, $0.lapseVariance * 100) } ?? Double(overall)

        let dims = [
            BrainDimension(key: "FOCUS",       label: "Focus hold",        fried: clampInt(attention),   blurb: attentionBlurb(attention)),
            BrainDimension(key: "SCROLL",      label: "Scroll pull",       fried: clampInt(dopamine),    blurb: dopamineBlurb(dopamine)),
            BrainDimension(key: "SLEEP",       label: "Sleep & mornings",  fried: clampInt(sleep),       blurb: sleepBlurb(sleep)),
            BrainDimension(key: "REFLEXES",    label: "Reflex speed",      fried: clampInt(reflexes),    blurb: reflexBlurb(reflexes)),
            BrainDimension(key: "CONSISTENCY", label: "Focus consistency", fried: clampInt(consistency), blurb: consistencyBlurb(consistency)),
        ]

        // Roughly half of the behaviour-driven load is genuinely recoverable; reflex/
        // consistency are more trait. Honest framing: a typical recovery target.
        let habitAvg = avg([attention, dopamine, sleep])
        let potential = max(8, overall - Int(habitAvg * 0.5))

        return BrainBreakdown(overall: overall, dimensions: dims,
                              percentile: percentile(overall: overall, age: age),
                              potential: potential)
    }

    /// "More fried than X% of people your age." Deterministic + monotonic; younger
    /// skews more fried so a given score is slightly less unusual, older slightly more.
    static func percentile(overall: Int, age: Int) -> Int {
        let ageAdj = Double(28 - max(13, min(70, age))) * 0.25
        return min(97, max(3, Int((Double(overall) * 0.9 + 6 + ageAdj).rounded())))
    }

    // MARK: - Honest, specific, second-person axis read-outs (the paid value)
    private static func attentionBlurb(_ v: Double) -> String {
        v >= 55 ? "You reach for your phone mid-task — your focus resets before it can build."
                : "You can hold a thread without bailing to your phone. Protect it."
    }
    private static func dopamineBlurb(_ v: Double) -> String {
        v >= 55 ? "Short-form video keeps you chasing the next hit — anything slower starts to feel boring."
                : "You're not hooked on quick hits. Rare these days."
    }
    private static func sleepBlurb(_ v: Double) -> String {
        v >= 55 ? "The day starts with a scroll — you're hooked on the feed before you're even fully awake."
                : "You don't hand the morning to your phone. That sets the whole day's tone."
    }
    private static func reflexBlurb(_ v: Double) -> String {
        v >= 55 ? "Your tap speed lagged — the classic vibe of a tired, over-stimulated headspace."
                : "Quick, clean reflexes. Your wiring's still sharp."
    }
    private static func consistencyBlurb(_ v: Double) -> String {
        v >= 55 ? "Your focus flickers — sharp one second, gone the next. The tell of a fried, scattered head."
                : "Steady, even focus across the test. That's the hard part to keep."
    }
}
