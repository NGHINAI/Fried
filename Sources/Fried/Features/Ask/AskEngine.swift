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
    @Published var lastReplyWasAI: Bool?               // nil until first reply; truth about THIS device
    @Published var typingId: UUID?                     // the reply currently typing itself in
    @Published private(set) var freeUsed = UserDefaults.standard.integer(forKey: "fried.ask.used")
    let freeLimit = 5

    var context = AskContext()

    func remaining(hasAccess: Bool) -> Int { hasAccess ? Int.max : max(0, freeLimit - freeUsed) }
    func canAsk(hasAccess: Bool) -> Bool { hasAccess || freeUsed < freeLimit }
    func clear() { messages = []; typingId = nil }

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
        let result = await AskEngine.answer(q, context: context, history: history)
        let reply = AskMessage(role: .brain, text: result.text)
        messages.append(reply)
        lastReplyWasAI = result.fromAI
        typingId = reply.id          // this one types itself in, live
        thinking = false
    }
}

enum AskEngine {
    /// Returns the reply AND whether it came from the live on-device model (true) or
    /// the templated fallback (false) — so the UI can tell the user the truth.
    static func answer(_ question: String, context: AskContext, history: [AskMessage]) async -> (text: String, fromAI: Bool) {
        if #available(iOS 26.0, *), let ai = await aiAnswer(question, context: context, history: history) {
            return (ai, true)
        }
        return (fallback(question, context: context, turn: history.count), false)
    }

    // MARK: On-device AI — the persuasion engine
    @available(iOS 26.0, *)
    private static func aiAnswer(_ question: String, context c: AskContext, history: [AskMessage]) async -> String? {
        #if canImport(FoundationModels)
        let model = SystemLanguageModel.default
        guard case .available = model.availability else { return nil }
        var instructions = systemPrompt(c)
        if !history.isEmpty {                                  // recap goes in INSTRUCTIONS, not the prompt,
            let recap = history.suffix(4)                      // so the model never echoes a turn label
                .map { ($0.role == .user ? "They said: " : "You replied: ") + $0.text }
                .joined(separator: "\n")
            instructions += "\n\nThe chat so far:\n\(recap)"
        }
        let session = LanguageModelSession { instructions }
        let opts = GenerationOptions(temperature: 0.8, maximumResponseTokens: 90)   // short = forced brevity
        do {
            let cleaned = clean(try await session.respond(to: question, options: opts).content)
            return cleaned.isEmpty ? nil : cleaned
        } catch { return nil }
        #else
        return nil
        #endif
    }

    /// Sanitize the small on-device model's output: strip any "Yolkie:" label it
    /// echoes, markdown emphasis, and heading/bullet markers. (internal = unit-tested)
    static func clean(_ raw: String) -> String {
        var s = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if let r = s.range(of: #"^\**\s*yolkie\s*:\**\s*"#, options: [.regularExpression, .caseInsensitive]) {
            s.removeSubrange(r)
        }
        s = s.replacingOccurrences(of: "**", with: "")
            .replacingOccurrences(of: "__", with: "")
            .replacingOccurrences(of: "###", with: "")
            .replacingOccurrences(of: "## ", with: "")
            .replacingOccurrences(of: "# ", with: "")
        // flatten any list the model sneaks in: drop "1. " / "- " / "* " markers, join lines
        let lines = s.components(separatedBy: .newlines).map { line -> String in
            var l = line.trimmingCharacters(in: .whitespaces)
            if let r = l.range(of: #"^(\d+[.)]|[-*•])\s+"#, options: .regularExpression) { l.removeSubrange(r) }
            return l
        }.filter { !$0.isEmpty }
        s = lines.joined(separator: " ")
        return s.trimmingCharacters(in: CharacterSet(charactersIn: " \n\"'"))
    }

    @available(iOS 26.0, *)
    private static func systemPrompt(_ c: AskContext) -> String {
        let goalLine = c.goal > 0 ? "; goal \(c.goal)% or lower" : ""
        return """
        You are Yolkie — a blunt, witty, caring brain coach in the Fried app. Talk like a text \
        from a sharp friend: 2 to 3 SHORT sentences, plain spoken English, nothing else.

        ABSOLUTE STYLE RULES:
        • NEVER use lists, numbered steps, bullet points, headings, markdown, or asterisks.
        • NEVER write your own name or a "Yolkie:" prefix. Just speak.
        • Keep it under ~45 words. Short and punchy beats thorough.

        WHAT YOU DO: answer anything, but always tie it to THEIR brain using their numbers below, \
        frame the cost as a LOSS, and END with ONE concrete action (e.g. "do one mission now", \
        "re-test tonight", "phone in another room for an hour"). A little dramatic, never cruel.

        THEIR DATA: \(c.score)/100 fried (\(c.tier)); brain age \(c.brainAge) vs real age \(c.realAge); \
        \(c.friedPercent)% fried, more than \(c.percentile)% of people their age; biggest leak \(c.topLeak); \
        \(c.streak)-day streak\(goalLine).

        NEVER claim medical or scientific facts; never mention real cognition, IQ, ADHD, attention \
        spans, or health conditions; never diagnose. It's a playful vibe check, not a measurement.
        """
    }

    // MARK: Offline fallback (no Apple Intelligence) — varied, intent-aware, loss-framed
    // + action-led. Rotates by turn so Yolkie never repeats himself.
    private static func fallback(_ q: String, context c: AskContext, turn: Int) -> String {
        let gap = max(0, c.brainAge - c.realAge)
        let leak = c.topLeak.lowercased()
        let lower = q.lowercased()
        func pick(_ arr: [String]) -> String { arr[abs(turn) % arr.count] }
        let yearsLine = gap > 0 ? "those \(gap) years" : "the points"

        if lower.contains("roast") || lower.contains("mean") {
            return pick([
                "You? \(c.friedPercent)% fried, brain age \(c.brainAge) at \(c.realAge) — and your \(leak) is doing the heavy lifting of ruining you. Bold to ask. Now go do a mission before I really start.",
                "Babe, you're more cooked than \(c.percentile)% of people your age and your big personality trait is \(leak). That's not a vibe, that's a warning label. Re-test tonight and prove me wrong.",
            ])
        }
        if lower.contains("fix") || lower.contains("how") || lower.contains("better") || lower.contains("help") || lower.contains("improve") {
            return pick([
                "Start with your biggest leak: \(leak). One de-fry mission today, re-test tonight. Small and daily beats heroic and never — that's how you claw \(yearsLine) back.",
                "Forget the overhaul. Do ONE thing now — a single mission aimed at \(leak) — then lock in a goal so you've got a finish line. Momentum is the whole game.",
            ])
        }
        if lower.contains("why") || lower.contains("fried") || lower.contains("so bad") {
            return pick([
                "You're \(c.friedPercent)% fried — more cooked than \(c.percentile)% of people your age — and it traces mostly to \(leak). Every day you ignore it, it sets a little deeper. Cool it down below.",
                "Short version: \(leak) is melting you. Brain age \(c.brainAge) vs your real \(c.realAge) — that gap is the receipt. Do one mission today and start tearing it up.",
            ])
        }
        if lower.contains("problem") || lower.contains("worst") || lower.contains("leak") || lower.contains("weak") {
            return "Your #1 leak is \(leak) — it's dragging everything else down with it. Fix that one and the whole score moves. Start with today's mission."
        }
        if lower.count <= 5 || lower.contains("ok") || lower.contains("sure") || lower.contains("thanks") || lower.contains("yes") || lower.contains("cool") {
            return pick([
                "Good. Then prove it — one mission, right now. I'll be watching your score.",
                "Talk's cheap, chef. Go cool your brain down and re-test tonight. \(gap > 0 ? "Those \(gap) years aren't clawing themselves back." : "")",
                "Love the energy. Channel it into one de-fry mission before you close this app.",
            ])
        }
        return pick([
            "Cute question — but I really only know one thing: your brain. \(c.friedPercent)% fried, biggest tell \(leak). Want the fix? Do a mission now.",
            "I'll be honest, I'm built to stare at your fried score (\(c.score)/100) and nag you better. Biggest leak: \(leak). Go handle it today.",
            "Off-topic, but I'll allow it. Back to you though: \(c.friedPercent)% fried, brain age \(c.brainAge). One mission today stops the slide.",
        ])
    }
}
