import Foundation

/// Deterministic fallback roasts used when on-device AI is unavailable, refuses,
/// or the device is ineligible. Every line is PG-13, self-directed, and
/// behavior-based (never appearance/identity) — required for App Review 1.1.1.
enum RoastBank {

    static func roast(for tier: FriedTier, seed: Int) -> String {
        let lines = bank[tier] ?? []
        guard !lines.isEmpty else { return "Unscored — but probably crispy." }
        let idx = abs(seed) % lines.count
        return lines[idx]
    }

    static let bank: [FriedTier: [String]] = [
        .crispMind: [
            "Look at you — actually able to focus when you want. Show-off.",
            "Certified Not Fried. Touch grass to keep it that way.",
            "Suspiciously locked in. Who are you."
        ],
        .lightlyToasted: [
            "Lightly toasted. A few too many “one more video”s, but you’ll live.",
            "Edges are crispy, center’s still soft. Salvageable.",
            "Mild scroll damage. Autoplay got a couple of you."
        ],
        .wellDone: [
            "Well done — not the compliment kind. The algorithm owns equity in you.",
            "You blinked and three hours of shorts happened. Classic.",
            "Halfway to goldfish. Your thumb has its own muscle memory now."
        ],
        .extraCrispy: [
            "Extra crispy. You opened this to avoid finishing something, didn’t you.",
            "Focus of a goldfish on espresso. Sizzling.",
            "A full workday of 15-second clips. The fryer is full."
        ],
        .deepFried: [
            "Deep fried. There’s no “before the For You page” version of you left.",
            "Crispy down to the soul. The algorithm sends its regards.",
            "You read this far? Genuinely impressed your brain held on."
        ]
    ]
}
