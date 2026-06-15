import Foundation
#if canImport(FoundationModels)
import FoundationModels
#endif

/// The verdict line. Tries Apple's on-device model (iOS 26, $0, fully private);
/// falls back to the curated, guardrail-safe RoastBank on any failure or older
/// device — so the reveal ALWAYS has a roast, on every iPhone, at zero cost.
enum RoastEngine {
    static func roast(for score: FriedScore) async -> String {
        if #available(iOS 26.0, *) {
            if let ai = await aiRoast(for: score) { return ai }
        }
        return RoastBank.roast(for: score.tier, seed: score.value)
    }

    @available(iOS 26.0, *)
    private static func aiRoast(for score: FriedScore) async -> String? {
        #if canImport(FoundationModels)
        let model = SystemLanguageModel.default
        guard case .available = model.availability else { return nil }

        // Tone-setting instructions keep it funny AND past the safety guardrail.
        let session = LanguageModelSession {
            """
            You are a witty, good-natured comedian. The user just got a playful \
            "fried score" from 0 to 100 measuring how scroll-fried and distracted \
            their phone habits are (higher = more fried). Reply with ONE short, \
            punchy, lighthearted teasing sentence about their score and scrolling \
            habits. Keep it PG-13 and warm — never about appearance, identity, \
            intelligence, or health. Output only the sentence, no quotes.
            """
        }
        let options = GenerationOptions(temperature: 1.3, maximumResponseTokens: 60)
        do {
            let response = try await session.respond(
                to: "Fried score: \(score.value) out of 100 (\(score.tier.title)). Give the one-line verdict.",
                options: options)
            let text = response.content.trimmingCharacters(in: CharacterSet(charactersIn: " \n\"'"))
            return text.isEmpty ? nil : text
        } catch {
            return nil   // guardrail trip, model-not-ready, etc. → RoastBank
        }
        #else
        return nil
        #endif
    }
}
