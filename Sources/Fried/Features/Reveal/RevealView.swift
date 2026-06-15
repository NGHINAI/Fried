import SwiftUI

struct RevealView: View {
    @EnvironmentObject var app: AppState
    @EnvironmentObject var store: Store
    @State private var roast = ""
    @State private var showRoast = false
    @State private var shareImage: Image?

    private var score: FriedScore { app.result ?? FriedScore(value: 0, tier: .crispMind) }
    private var locked: Bool { !store.hasAccess }

    var body: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 8)
            Text("YOUR FRIED SCORE")
                .font(Theme.label(14)).tracking(2.5).foregroundStyle(Theme.textSecondary)

            ZStack {
                scoreBlock
                    .blur(radius: locked ? 26 : 0)
                    .allowsHitTesting(!locked)
                if locked { lockOverlay }
            }

            Spacer(minLength: 8)
            ctaButtons
            Text("For entertainment only — a playful vibe check, not a measurement of your health, focus, or intelligence.")
                .font(.system(size: 11, weight: .regular, design: .rounded))
                .foregroundStyle(Theme.textSecondary.opacity(0.65))
                .multilineTextAlignment(.center).padding(.horizontal, 28).padding(.bottom, 8)
        }
        .task {
            roast = await RoastEngine.roast(for: score)
            shareImage = ShareCard.image(score: score, roast: roast)
            withAnimation(.easeOut(duration: 0.5).delay(0.9)) { showRoast = true }
        }
    }

    private var scoreBlock: some View {
        VStack(spacing: 20) {
            ScoreDial(score: score.value, tier: score.tier)
            Text("\(score.tier.emoji)  \(score.tier.title)")
                .font(Theme.title(30)).foregroundStyle(Theme.textPrimary)
            GlassCard {
                Text(roast.isEmpty ? " " : roast)
                    .font(Theme.body(18)).foregroundStyle(Theme.textPrimary)
                    .multilineTextAlignment(.center).padding(22).frame(maxWidth: .infinity)
            }
            .padding(.horizontal, Theme.pad)
            .opacity(showRoast ? 1 : 0).offset(y: showRoast ? 0 : 12)
        }
    }

    private var lockOverlay: some View {
        VStack(spacing: 10) {
            Image(systemName: "lock.fill").font(.system(size: 30, weight: .bold)).foregroundStyle(Theme.amber)
            Text("Your results are in.").font(Theme.title(24)).foregroundStyle(Theme.textPrimary)
            Text("Unlock to see how fried you really are —\nplus your breakdown & de-fry plan.")
                .font(Theme.body(15)).foregroundStyle(Theme.textSecondary).multilineTextAlignment(.center)
        }
        .padding(28)
    }

    @ViewBuilder private var ctaButtons: some View {
        VStack(spacing: 12) {
            if locked {
                PrimaryButton(title: "Reveal my results", subtitle: "\(store.fullPriceText) once · no subscription") {
                    app.paywallReturn = .reveal
                    withAnimation { app.screen = .paywall }
                }
                ShareLink(item: URL(string: "https://fried.app")!,
                          message: Text("How fried is your brain? Find out 🍳")) {
                    Text("…or invite 3 friends to reveal it free")
                        .font(Theme.body(15)).fontWeight(.semibold).foregroundStyle(Theme.amber)
                }
                .simultaneousGesture(TapGesture().onEnded { store.invitedUnlock = true })
            } else {
                PrimaryButton(title: "See my full breakdown") {
                    withAnimation { app.screen = .home }
                }
                if let shareImage {
                    ShareLink(item: shareImage,
                              message: Text("How fried is your brain? I scored \(score.value) 🍳 fried.app"),
                              preview: SharePreview("My Fried Score", image: shareImage)) {
                        Label("Share my score", systemImage: "square.and.arrow.up")
                            .font(Theme.body(16)).foregroundStyle(Theme.textSecondary)
                    }
                }
            }
        }
        .padding(.horizontal, Theme.pad)
    }
}
