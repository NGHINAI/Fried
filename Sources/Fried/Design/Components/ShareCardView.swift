import SwiftUI

/// The shareable 9:16 score card — the viral loop. Solid colors only (no
/// materials) so ImageRenderer exports it crisply off-screen.
struct ShareCardView: View {
    let score: FriedScore
    let roast: String

    var body: some View {
        ZStack {
            LinearGradient(colors: [Theme.void, Theme.color(for: score.tier).opacity(0.30), Theme.void],
                           startPoint: .top, endPoint: .bottom)
            VStack(spacing: 30) {
                Spacer()
                Text("MY FRIED SCORE")
                    .font(Theme.label(26)).tracking(4)
                    .foregroundStyle(Theme.textSecondary)
                ZStack {
                    Circle().stroke(.white.opacity(0.10), lineWidth: 24)
                    Circle().trim(from: 0, to: Double(score.value) / 100)
                        .stroke(Theme.gradient(for: score.tier),
                                style: StrokeStyle(lineWidth: 24, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    VStack(spacing: -8) {
                        Text("\(score.value)").font(Theme.score(150))
                            .foregroundStyle(Theme.gradient(for: score.tier))
                        Text("/ 100").font(Theme.label(28)).foregroundStyle(Theme.textSecondary)
                    }
                }
                .frame(width: 420, height: 420)
                Text("\(score.tier.emoji)  \(score.tier.title)")
                    .font(Theme.title(50)).foregroundStyle(Theme.textPrimary)
                Text(roast)
                    .font(Theme.body(30)).foregroundStyle(Theme.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 70)
                Spacer()
                Text("🍳  fried.app")
                    .font(Theme.title(34)).foregroundStyle(Theme.amber)
                    .padding(.bottom, 20)
            }
            .padding(60)
        }
        .frame(width: 900, height: 1600)
    }
}

@MainActor
enum ShareCard {
    /// Renders the card to a shareable Image. Returns nil if rendering fails.
    static func image(score: FriedScore, roast: String) -> Image? {
        let renderer = ImageRenderer(content: ShareCardView(score: score, roast: roast))
        renderer.scale = 2
        guard let ui = renderer.uiImage else { return nil }
        return Image(uiImage: ui)
    }
}
