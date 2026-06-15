import Foundation
#if canImport(FoundationModels)
import FoundationModels
#endif

/// A personalized written read derived from the user's actual data.
struct FriedAnalysis {
    let summary: String       // 2–3 sentence personalized analysis
    let insights: [String]    // specific observations
}

/// Sends the user's real quiz + reaction + score to Apple's on-device model and
/// gets back a genuine analysis (not just math). Falls back to a data-driven
/// template when Apple Intelligence is unavailable — so every phone gets a read.
enum AnalysisEngine {
    static func analyze(score: FriedScore, quiz: QuizResult?, reaction: ReactionResult?) async -> FriedAnalysis {
        let insights = deterministicInsights(score: score, quiz: quiz, reaction: reaction)
        if #available(iOS 26.0, *) {
            if let summary = await aiSummary(score: score, quiz: quiz, reaction: reaction) {
                return FriedAnalysis(summary: summary, insights: insights)
            }
        }
        return FriedAnalysis(summary: templateSummary(score: score), insights: insights)
    }

    // MARK: On-device AI
    @available(iOS 26.0, *)
    private static func aiSummary(score: FriedScore, quiz: QuizResult?, reaction: ReactionResult?) async -> String? {
        #if canImport(FoundationModels)
        let model = SystemLanguageModel.default
        guard case .available = model.availability else { return nil }

        let session = LanguageModelSession {
            """
            You are a witty but insightful analyst. You'll be given someone's data \
            from a playful "brain rot" check: a fried score (0–100, higher = more \
            scroll-fried), their reaction-time results, and their self-reported \
            phone habits. Write 2–3 short sentences analyzing what their data says \
            about their focus and scrolling — be specific to the numbers given, \
            warm, a little cheeky, and end with one encouraging nudge. PG-13. \
            Never mention appearance, identity, intelligence, or medical/health \
            claims, and never claim to measure attention span, cognition, IQ, or \
            a medical condition. Output only the analysis text.
            """
        }
        let options = GenerationOptions(temperature: 1.0, maximumResponseTokens: 130)
        do {
            let response = try await session.respond(to: dataString(score: score, quiz: quiz, reaction: reaction),
                                                     options: options)
            let text = response.content.trimmingCharacters(in: CharacterSet(charactersIn: " \n\"'"))
            return text.isEmpty ? nil : text
        } catch {
            return nil
        }
        #else
        return nil
        #endif
    }

    private static func dataString(score: FriedScore, quiz: QuizResult?, reaction: ReactionResult?) -> String {
        var parts = ["Fried score: \(score.value)/100 (\(score.tier.title))."]
        if let r = reaction {
            let steady = r.lapseVariance < 0.3 ? "steady" : "erratic"
            parts.append("Average reaction time: \(Int(r.meanMillis))ms, \(steady).")
        }
        if let q = quiz {
            let lines = QuizContent.questions.enumerated().compactMap { i, question -> String? in
                guard i < q.answerIndices.count else { return nil }
                let idx = min(q.answerIndices[i], question.answers.count - 1)
                return "\(question.prompt) → \(question.answers[idx])"
            }
            parts.append("Habits: " + lines.joined(separator: "; ") + ".")
        }
        return parts.joined(separator: " ")
    }

    // MARK: Deterministic fallback (data-driven, no AI)
    private static func deterministicInsights(score: FriedScore, quiz: QuizResult?, reaction: ReactionResult?) -> [String] {
        var out: [String] = []
        if let r = reaction {
            out.append(r.meanMillis > 360
                ? "Your reflexes are lagging (\(Int(r.meanMillis))ms) — a classic fried-feed tell."
                : "Sharp reflexes (\(Int(r.meanMillis))ms) — your focus core is holding up.")
            if r.lapseVariance > 0.4 {
                out.append("Your taps were all over the place — focus flickering in and out.")
            }
        }
        if let q = quiz, !q.answerIndices.isEmpty {
            let heavy = q.answerIndices.reduce(0, +)
            let max = q.maxIndex * q.answerIndices.count
            out.append(Double(heavy) / Double(max) > 0.6
                ? "Your habits skew heavy — the algorithm has a comfortable seat in your head."
                : "Your habits are fairly tame — you're mostly still driving.")
        }
        out.append(score.tier == .crispMind || score.tier == .lightlyToasted
            ? "Keep it up — you're more in control than most."
            : "The good news: a few small swaps and this number drops fast.")
        return Array(out.prefix(3))
    }

    private static func templateSummary(score: FriedScore) -> String {
        switch score.tier {
        case .crispMind:
            return "Your data says you're genuinely locked in — fast, steady, and light on the doomscroll. Rare. Protect it."
        case .lightlyToasted:
            return "You're mostly sharp with a few soft spots where autoplay sneaks in. Nothing a couple of phone-free hours won't fix."
        case .wellDone:
            return "The numbers don't lie — your reflexes and habits both took a hit from the feed. You're squarely in algorithm territory, but it's very reversible."
        case .extraCrispy:
            return "Your reactions are slowing and your habits are heavy — the For You page is doing real laps in your head. Time for a de-fry."
        case .deepFried:
            return "Every signal points the same way: deeply, gloriously fried. The algorithm sends its regards. One small change this week would go a long way."
        }
    }
}
