import SwiftUI

/// The shareable 9:16 score card — the viral loop. Solid near-black (survives
/// reposting over busy story backgrounds), one HERO number, the current→potential
/// gap (the aspiration that drives retakes + replies), a percentile (quantified
/// belonging), and embedded branding + a "beat my score" CTA (the recruitment
/// mechanism). 1080×1920 with ~250px top/bottom safe zones for IG/TikTok overlays.
struct ShareCardView: View {
    let score: FriedScore
    let breakdown: BrainBreakdown
    let roast: String

    private var accent: LinearGradient { Theme.gradient(for: score.tier) }

    var body: some View {
        ZStack {
            Theme.void
            RadialGradient(colors: [Theme.color(for: score.tier).opacity(0.34), .clear],
                           center: UnitPoint(x: 0.5, y: 0.34), startRadius: 30, endRadius: 560)

            VStack(spacing: 0) {
                Spacer().frame(height: 250)                       // top safe zone

                Text("F R I E D").font(.system(size: 40, weight: .bold)).tracking(6)
                    .foregroundStyle(Theme.amber.opacity(0.85))

                Spacer()

                Text("MY FRY SCORE").font(.system(size: 30, weight: .medium)).tracking(5)
                    .foregroundStyle(Theme.textSecondary)
                Text("\(score.value)").font(Theme.hero(300)).foregroundStyle(accent)
                    .shadow(color: Theme.color(for: score.tier).opacity(0.5), radius: 40)
                Text("\(score.tier.emoji)  \(score.tier.title.uppercased())")
                    .font(.system(size: 64, weight: .bold)).foregroundStyle(Theme.textPrimary)
                    .padding(.top, 8)

                gapBar.padding(.top, 54).padding(.horizontal, 90)

                Text("🔥 More fried than \(breakdown.percentile)% of brains")
                    .font(.system(size: 34, weight: .medium)).foregroundStyle(Theme.textPrimary.opacity(0.85))
                    .padding(.top, 40)

                Spacer()

                VStack(spacing: 10) {
                    Text("How fried is YOUR brain?").font(.system(size: 38, weight: .semibold))
                        .foregroundStyle(Theme.textPrimary)
                    Text("🍳  fried.app").font(.system(size: 34, weight: .bold)).foregroundStyle(Theme.amber)
                }
                Spacer().frame(height: 250)                       // bottom safe zone
            }
            .multilineTextAlignment(.center)
        }
        .frame(width: 1080, height: 1920)
    }

    // The current → recoverable gap: the aspiration + the reason to retake/share.
    private var gapBar: some View {
        VStack(spacing: 16) {
            HStack {
                poleLabel("YOU", score.value, Theme.danger)
                Spacer()
                poleLabel("RECOVERABLE", breakdown.potential, Theme.recovery)
            }
            GeometryReader { g in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.10))
                    Capsule().fill(LinearGradient(colors: [Theme.recovery, Theme.danger],
                                                  startPoint: .leading, endPoint: .trailing))
                        .frame(width: g.size.width * CGFloat(score.value) / 100)
                }
            }
            .frame(height: 18)
        }
    }
    private func poleLabel(_ tag: String, _ value: Int, _ color: Color) -> some View {
        VStack(spacing: 2) {
            Text(tag).font(.system(size: 22, weight: .semibold)).tracking(2).foregroundStyle(Theme.textSecondary)
            Text("\(value)").font(Theme.hero(58)).foregroundStyle(color)
        }
    }
}

@MainActor
enum ShareCard {
    /// Renders the card to a shareable Image. Returns nil if rendering fails.
    static func image(score: FriedScore, breakdown: BrainBreakdown, roast: String) -> Image? {
        let renderer = ImageRenderer(content: ShareCardView(score: score, breakdown: breakdown, roast: roast))
        renderer.scale = 1                              // view is already at full 1080×1920 px
        guard let ui = renderer.uiImage else { return nil }
        return Image(uiImage: ui)
    }
}
