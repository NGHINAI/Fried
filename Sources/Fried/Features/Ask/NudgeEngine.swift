import Foundation
#if canImport(FoundationModels)
import FoundationModels
#endif

/// AI reminders — Yolkie writes the daily 7pm push ON-DEVICE from that day's data,
/// so the nudge is personal and loss-framed instead of generic. Falls back to sharp
/// templates with no Apple Intelligence. Ethical: no medical claims, never fabricated.
enum NudgeEngine {
    struct Nudge { let title: String; let body: String }

    static func daily(friedPercent: Int, brainAge: Int, realAge: Int, topLeak: String, streak: Int) async -> Nudge {
        if #available(iOS 26.0, *),
           let ai = await ai(friedPercent: friedPercent, brainAge: brainAge, realAge: realAge, topLeak: topLeak, streak: streak) {
            return ai
        }
        return fallback(friedPercent: friedPercent, topLeak: topLeak, streak: streak)
    }

    @available(iOS 26.0, *)
    private static func ai(friedPercent: Int, brainAge: Int, realAge: Int, topLeak: String, streak: Int) async -> Nudge? {
        #if canImport(FoundationModels)
        let model = SystemLanguageModel.default
        guard case .available = model.availability else { return nil }
        let session = LanguageModelSession {
            """
            You are Yolkie, a witty brain coach. Write ONE short push notification that \
            pulls the user back to cool their fried brain down tonight. Loss-framed, names \
            their weak spot, one clear nudge, a little alarming but warm. Never claim medical \
            or scientific facts, never mention real cognition/IQ/health. Respond EXACTLY as:
            TITLE: <max 6 words, may include one emoji>
            BODY: <max 18 words>
            """
        }
        let opts = GenerationOptions(temperature: 1.1, maximumResponseTokens: 80)
        let prompt = "Data: \(friedPercent)% fried, brain age \(brainAge) vs \(realAge), biggest leak \(topLeak), \(streak)-day streak. Write tonight's reminder."
        do {
            let text = try await session.respond(to: prompt, options: opts).content
            var title = "", body = ""
            for raw in text.split(separator: "\n") {
                let l = raw.trimmingCharacters(in: .whitespaces)
                if let r = l.range(of: "TITLE:", options: .caseInsensitive) {
                    title = String(l[r.upperBound...]).trimmingCharacters(in: CharacterSet(charactersIn: " \"'"))
                } else if let r = l.range(of: "BODY:", options: .caseInsensitive) {
                    body = String(l[r.upperBound...]).trimmingCharacters(in: CharacterSet(charactersIn: " \"'"))
                }
            }
            guard !title.isEmpty, !body.isEmpty, title.count <= 60 else { return nil }
            return Nudge(title: title, body: body)
        } catch { return nil }
        #else
        return nil
        #endif
    }

    private static func fallback(friedPercent: Int, topLeak: String, streak: Int) -> Nudge {
        let leak = topLeak.lowercased()
        if streak >= 2 {
            return Nudge(title: "🔥 Your \(streak)-day streak ends tonight",
                         body: "One 60-second check keeps it alive. Your \(leak) needs you.")
        }
        if friedPercent >= 60 {
            return Nudge(title: "Your brain is \(friedPercent)% fried 🍳",
                         body: "It crisped up today — mostly \(leak). Cool it down before bed.")
        }
        return Nudge(title: "Your brain is frying 🍳",
                     body: "60 seconds to cool it down. Don't let today set in.")
    }
}
