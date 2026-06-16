import Foundation
#if canImport(FoundationModels)
import FoundationModels
#endif

/// An AI-generated "brain archetype" — a unique, witty identity (like a tarot card
/// or a "which ___ are you" result) written ON-DEVICE from the user's vibe-check
/// data. Identity-as-currency (the share driver) + variable reward (re-roll). One
/// on-device call, cached; a deterministic bank guarantees something great offline.
struct BrainArchetype: Codable, Equatable {
    let title: String     // "The Doomscroll Sommelier"
    let blurb: String     // 2–3 punchy, personal sentences
    let sig: String       // cache signature
}

enum ArchetypeEngine {
    static func make(score: FriedScore, breakdown: BrainBreakdown, reroll: Int) async -> BrainArchetype {
        var title = fallbackTitle(score: score, reroll: reroll)
        var blurb = fallbackBlurb(score: score, breakdown: breakdown)
        if #available(iOS 26.0, *), let ai = await aiArchetype(score: score, breakdown: breakdown, reroll: reroll) {
            title = ai.title; blurb = ai.blurb
        }
        return BrainArchetype(title: title, blurb: blurb,
                              sig: signature(score: score, breakdown: breakdown, reroll: reroll))
    }

    static func signature(score: FriedScore, breakdown: BrainBreakdown, reroll: Int) -> String {
        "\(score.value)|\(breakdown.topLeak.key)|\(reroll)"
    }

    // MARK: On-device AI (the wow)
    @available(iOS 26.0, *)
    private static func aiArchetype(score: FriedScore, breakdown: BrainBreakdown, reroll: Int) async -> (title: String, blurb: String)? {
        #if canImport(FoundationModels)
        let model = SystemLanguageModel.default
        guard case .available = model.availability else { return nil }
        let session = LanguageModelSession {
            """
            You are Yolkie, a witty fried-egg mascot. Invent an ORIGINAL, funny \
            "brain archetype" for someone from their playful fried-brain vibe-check — \
            like a tarot card or a "which ___ are you" result. Specific, characterful, \
            a little roasty but affectionate. Never mention real medical facts, \
            cognition, IQ, attention spans, or health conditions. Respond in EXACTLY \
            this format and nothing else:
            TITLE: <a 2 to 4 word archetype name>
            PROFILE: <2 to 3 punchy sentences, second person>
            """
        }
        let opts = GenerationOptions(temperature: 1.2, maximumResponseTokens: 150)
        let prompt = """
        Fried score \(score.value)/100 (\(score.tier.title)); biggest tell: \
        \(breakdown.topLeak.label) (\(breakdown.topLeak.fried)/100); strongest: \
        \(breakdown.strongest.label). Variation seed \(reroll). Write their archetype.
        """
        do { return parse(try await session.respond(to: prompt, options: opts).content) }
        catch { return nil }
        #else
        return nil
        #endif
    }

    private static func parse(_ text: String) -> (title: String, blurb: String)? {
        var title = "", blurb = ""
        for raw in text.split(separator: "\n") {
            let l = raw.trimmingCharacters(in: .whitespaces)
            if let r = l.range(of: "TITLE:", options: .caseInsensitive) {
                title = String(l[r.upperBound...]).trimmingCharacters(in: CharacterSet(charactersIn: " \"'"))
            } else if let r = l.range(of: "PROFILE:", options: .caseInsensitive) {
                blurb = String(l[r.upperBound...]).trimmingCharacters(in: CharacterSet(charactersIn: " \"'"))
            } else if !blurb.isEmpty {
                blurb += " " + l
            }
        }
        guard !title.isEmpty, title.count <= 40, !blurb.isEmpty else { return nil }
        return (title, blurb)
    }

    // MARK: Deterministic fallback (selected by tier + reroll) — always great offline
    private static func fallbackTitle(score: FriedScore, reroll: Int) -> String {
        let bank: [String]
        switch score.tier {
        case .crispMind:      bank = ["The Untouchable", "Galaxy Brain", "The Monk"]
        case .lightlyToasted: bank = ["The Functional Scroller", "Lightly Singed", "The Optimist"]
        case .wellDone:       bank = ["The Doomscroll Diplomat", "Medium-Rare Mind", "The Tab Hoarder"]
        case .extraCrispy:    bank = ["The Feed Goblin", "Reply-Guy Royalty", "The 3 AM Scroller"]
        case .deepFried:      bank = ["The Doomscroll Sommelier", "Certified Brainrot", "The Algorithm's Pet"]
        }
        return bank[abs(reroll) % bank.count]
    }
    private static func fallbackBlurb(score: FriedScore, breakdown: BrainBreakdown) -> String {
        "Your biggest tell is \(breakdown.topLeak.label.lowercased()). You're \(score.value)% fried — \(score.tier.title.lowercased()) — but your \(breakdown.strongest.label.lowercased()) is still holding the line. There's a comeback buried in here."
    }
}

/// Holds the user's archetype; generates once and on explicit re-roll. Persisted.
@MainActor
final class ArchetypeStore: ObservableObject {
    @Published private(set) var archetype: BrainArchetype?
    @Published private(set) var loading = false
    private var rerollCount = 0
    private let key = "fried.archetype.v1"

    init() {
        if let data = UserDefaults.standard.data(forKey: key),
           let a = try? JSONDecoder().decode(BrainArchetype.self, from: data) {
            archetype = a
        }
    }

    func ensure(score: FriedScore, breakdown: BrainBreakdown) async {
        let sig = ArchetypeEngine.signature(score: score, breakdown: breakdown, reroll: rerollCount)
        if let a = archetype, a.sig == sig { return }
        await generate(score: score, breakdown: breakdown)
    }

    func reroll(score: FriedScore, breakdown: BrainBreakdown) async {
        rerollCount += 1
        await generate(score: score, breakdown: breakdown)
    }

    private func generate(score: FriedScore, breakdown: BrainBreakdown) async {
        loading = true
        let a = await ArchetypeEngine.make(score: score, breakdown: breakdown, reroll: rerollCount)
        archetype = a
        if let d = try? JSONEncoder().encode(a) { UserDefaults.standard.set(d, forKey: key) }
        loading = false
    }
}
