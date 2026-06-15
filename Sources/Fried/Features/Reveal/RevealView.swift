import SwiftUI

struct RevealView: View {
    @EnvironmentObject var app: AppState
    @EnvironmentObject var store: Store
    @State private var roast = ""
    @State private var showRoast = false
    @State private var shareImage: Image?

    private var score: FriedScore { app.result ?? FriedScore(value: 0, tier: .crispMind) }

    var body: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 8)
            Text("YOUR FRIED SCORE")
                .font(Theme.label(14)).tracking(2.5)
                .foregroundStyle(Theme.textSecondary)
            ScoreDial(score: score.value, tier: score.tier)
            Text("\(score.tier.emoji)  \(score.tier.title)")
                .font(Theme.title(30))
                .foregroundStyle(Theme.textPrimary)
            GlassCard {
                Text(roast.isEmpty ? " " : roast)
                    .font(Theme.body(18))
                    .foregroundStyle(Theme.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(22)
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, Theme.pad)
            .opacity(showRoast ? 1 : 0)
            .offset(y: showRoast ? 0 : 12)
            Spacer(minLength: 8)
            VStack(spacing: 12) {
                if store.hasAccess {
                    PrimaryButton(title: "See my full breakdown") {
                        withAnimation { app.screen = .home }
                    }
                } else {
                    PrimaryButton(title: "Unlock my full breakdown",
                                  subtitle: "\(store.priceText) once · no subscription") {
                        app.paywallReturn = .reveal
                        withAnimation { app.screen = .paywall }
                    }
                }
                if let shareImage {
                    ShareLink(item: shareImage,
                              message: Text("How fried is your brain? I scored \(score.value) 🍳 fried.app"),
                              preview: SharePreview("My Fried Score", image: shareImage)) {
                        Label("Share my score", systemImage: "square.and.arrow.up")
                            .font(Theme.body(16)).foregroundStyle(Theme.textSecondary)
                    }
                } else {
                    Label("Share my score", systemImage: "square.and.arrow.up")
                        .font(Theme.body(16)).foregroundStyle(Theme.textSecondary.opacity(0.4))
                }
            }
            .padding(.horizontal, Theme.pad)
            Text("For entertainment only — a playful vibe check, not a measurement of your health, focus, or intelligence.")
                .font(.system(size: 11, weight: .regular, design: .rounded))
                .foregroundStyle(Theme.textSecondary.opacity(0.65))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 28)
                .padding(.bottom, 8)
        }
        .task {
            roast = await RoastEngine.roast(for: score)
            shareImage = ShareCard.image(score: score, roast: roast)
            withAnimation(.easeOut(duration: 0.5).delay(0.9)) { showRoast = true }
        }
    }
}
