import Foundation
#if canImport(FoundationModels)
import FoundationModels
#endif

/// "Ask your brain" — a conversational, on-device AI coach. Every answer is
/// grounded in the user's real numbers, framed as a loss, and ends with ONE
/// concrete action — engineered to make the user FEEL they need to act now.
/// 5 free questions, then the paywall. Ethical: no medical claims, never fabricated.

struct AskMessage: Identifiable, Equatable {
    enum Role { case user, brain }
    let id = UUID()
    let role: Role
    var text: String
}

/// Everything the coach personalizes from (set by the view before asking).
struct AskContext {
    var score = 0
    var tier = "Crisp Mind"
    var brainAge = 0
    var realAge = 0
    var friedPercent = 0
    var percentile = 50
    var topLeak = "focus"
    var streak = 0
    var goal = 0
}

@MainActor
final class AskStore: ObservableObject {
    @Published var messages: [AskMessage] = []
    @Published var thinking = false
    @Published private(set) var freeUsed = UserDefaults.standard.integer(forKey: "fried.ask.used")
    let freeLimit = 5

    var context = AskContext()

    func remaining(hasAccess: Bool) -> Int { hasAccess ? Int.max : max(0, freeLimit - freeUsed) }
    func canAsk(hasAccess: Bool) -> Bool { hasAccess || freeUsed < freeLimit }

    func ask(_ question: String, hasAccess: Bool) async {
        let q = question.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty, !thinking, canAsk(hasAccess: hasAccess) else { return }
        let history = messages
        messages.append(AskMessage(role: .user, text: q))
        if !hasAccess {
            freeUsed += 1
            UserDefaults.standard.set(freeUsed, forKey: "fried.ask.used")
        }
        thinking = true
        let answer = await AskEngine.answer(q, context: context, history: history)
        messages.append(AskMessage(role: .brain, text: answer))
        thinking = false
    }
}

enum AskEngine {
    static func answer(_ question: String, context: AskContext, history: [AskMessage]) async -> String {
        if #available(iOS 26.0, *), let ai = await aiAnswer(question, context: context, history: history) {
            return ai
        }
        return fallback(question, context: context)
    }

    // MARK: On-device AI — the persuasion engine
    @available(iOS 26.0, *)
    private static func aiAnswer(_ question: String, context c: AskContext, history: [AskMessage]) async -> String? {
        #if canImport(FoundationModels)
        let model = SystemLanguageModel.default
        guard case .available = model.availability else { return nil }
        let session = LanguageModelSession { systemPrompt(c) }
        let opts = GenerationOptions(temperature: 1.0, maximumResponseTokens: 200)
        var prompt = ""
        for m in history.suffix(6) {
            prompt += (m.role == .user ? "User: " : "Yolkie: ") + m.text + "\n"
        }
        prompt += "User: \(question)\nYolkie:"
        do {
            let text = try await session.respond(to: prompt, options: opts).content
                .trimmingCharacters(in: CharacterSet(charactersIn: " \n\"'"))
            return text.isEmpty ? nil : text
        } catch { return nil }
        #else
        return nil
        #endif
    }

    @available(iOS 26.0, *)
    private static func systemPrompt(_ c: AskContext) -> String {
        let goalLine = c.goal > 0 ? ", their goal is \(c.goal)% fried or lower" : ""
        return """
        You are Yolkie — the user's brutally honest but caring brain coach inside Fried, \
        a playful "how fried is your brain" app. You can answer ANYTHING they ask, but you \
        ALWAYS make it about THEIR brain and THEIR real numbers, and you ALWAYS end by pushing \
        them toward ONE concrete action right now.

        THE USER'S REAL DATA (cite it, make it personal):
        - Fried score \(c.score)/100 (\(c.tier))
        - Brain age \(c.brainAge) vs real age \(c.realAge)
        - \(c.friedPercent)% fried, more fried than \(c.percentile)% of people their age
        - Biggest leak: \(c.topLeak)
        - \(c.streak)-day streak\(goalLine)

        YOUR JOB:
        1. Make them FEEL the cost of their habits — honestly, using the numbers above. Name their specific weak spot.
        2. Frame it as a LOSS: what they're losing now, what gets worse if they wait, what they could reclaim.
        3. ALWAYS end with ONE specific, doable action ("do today's mission", "re-test tonight", "lock in a goal", "phone in another room for an hour"). Make them feel they need to act NOW.
        4. Be vivid and a little alarming, but never cruel — you want them to win.

        STYLE: 2–4 short sentences. Second person, present tense. Punchy, warm, a little dramatic. PG-13.

        HARD RULES: Never claim medical or scientific facts. Never mention real cognition, IQ, ADHD, dopamine-as-medicine, attention spans, or any health condition. Never diagnose. This is a playful vibe check, not a measurement. If they ask something off-topic, answer briefly in character, then pivot back to their brain and an action.
        """
    }

    // MARK: Offline fallback (no Apple Intelligence) — still loss-framed + action-led
    private static func fallback(_ q: String, context c: AskContext) -> String {
        let gap = max(0, c.brainAge - c.realAge)
        let leak = c.topLeak.lowercased()
        let lower = q.lowercased()
        if lower.contains("fix") || lower.contains("how") || lower.contains("better") || lower.contains("help") {
            return "Your biggest leak is \(leak). Fix that one first: do a single de-fry mission today and re-test tonight. Small and daily beats heroic and never — that's how you claw \(gap > 0 ? "those \(gap) years" : "points") back. Start now, not tomorrow."
        }
        if lower.contains("why") || lower.contains("fried") || lower.contains("bad") {
            return "You're \(c.friedPercent)% fried — more cooked than \(c.percentile)% of people your age — and it traces mostly to \(leak). It's not permanent, but every day you ignore it, it sets a little deeper. Cool it down below before it sticks."
        }
        return "Straight talk: brain age \(c.brainAge) vs your real \(c.realAge), \(c.friedPercent)% fried, biggest tell \(leak). Most of it is reversible — but only if you move today. Do one mission right now and prove it to yourself."
    }
}
