import SwiftUI

/// The shareable 9:16 card — now built around the AI ARCHETYPE (the identity is the
/// viral artifact). Solid near-black (survives reposting), the egg, the archetype
/// title as hero, the score + percentile as supporting stats, branding + CTA.
/// 1080×1920 with ~220px top/bottom safe zones for IG/TikTok overlays.
struct ShareCardView: View {
    let score: FriedScore
    let breakdown: BrainBreakdown
    let archetype: BrainArchetype?
    let roast: String

    private var accent: LinearGradient { Theme.gradient(for: score.tier) }
    private var title: String { (archetype?.title ?? score.tier.title).uppercased() }

    var body: some View {
        ZStack {
            Theme.void
            RadialGradient(colors: [Theme.color(for: score.tier).opacity(0.34), .clear],
                           center: UnitPoint(x: 0.5, y: 0.40), startRadius: 30, endRadius: 620)

            VStack(spacing: 0) {
                Spacer().frame(height: 210)
                Text("F R I E D").font(.system(size: 38, weight: .bold)).tracking(6)
                    .foregroundStyle(Theme.amber.opacity(0.85))
                Spacer()
                Text("MY BRAIN TYPE").font(.system(size: 29, weight: .medium)).tracking(5)
                    .foregroundStyle(Theme.textSecondary)
                EggMascot(mood: .forFreshness(Double(100 - score.value)), friedLevel: Double(score.value) / 100, size: 230)
                    .padding(.top, 4)
                Text(title)
                    .font(.system(size: 86, weight: .bold)).foregroundStyle(accent)
                    .multilineTextAlignment(.center).lineLimit(2).minimumScaleFactor(0.5)
                    .shadow(color: Theme.color(for: score.tier).opacity(0.5), radius: 34)
                    .padding(.horizontal, 56).padding(.top, 4)
                Text("Fry Score \(score.value)/100 · \(score.tier.title)")
                    .font(.system(size: 35, weight: .semibold)).foregroundStyle(Theme.textPrimary).padding(.top, 24)
                Text("🔥 More fried than \(breakdown.percentile)% of brains")
                    .font(.system(size: 31, weight: .medium)).foregroundStyle(Theme.textPrimary.opacity(0.8)).padding(.top, 12)
                Spacer()
                VStack(spacing: 10) {
                    Text("What's YOUR brain type?").font(.system(size: 37, weight: .semibold)).foregroundStyle(Theme.textPrimary)
                    Text("🍳  fried.app").font(.system(size: 34, weight: .bold)).foregroundStyle(Theme.amber)
                }
                Spacer().frame(height: 210)
            }
            .multilineTextAlignment(.center)
        }
        .frame(width: 1080, height: 1920)
    }
}

@MainActor
enum ShareCard {
    /// Renders the card to a shareable Image. Returns nil if rendering fails.
    static func image(score: FriedScore, breakdown: BrainBreakdown, archetype: BrainArchetype?, roast: String) -> Image? {
        let renderer = ImageRenderer(content: ShareCardView(score: score, breakdown: breakdown, archetype: archetype, roast: roast))
        renderer.scale = 1
        guard let ui = renderer.uiImage else { return nil }
        return Image(uiImage: ui)
    }
}
