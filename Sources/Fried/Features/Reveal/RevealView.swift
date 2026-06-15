import SwiftUI

struct RevealView: View {
    @EnvironmentObject var app: AppState
    @State private var roast = ""
    @State private var showRoast = false

    private var score: FriedScore { app.result ?? FriedScore(value: 0, tier: .crispMind) }

    var body: some View {
        VStack(spacing: 22) {
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
                PrimaryButton(title: "Unlock my full breakdown",
                              subtitle: "$4.99 once · no subscription") {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                        app.screen = .paywall
                    }
                }
                Button {
                    // ShareCard export wired in Task 10
                } label: {
                    Label("Share my score", systemImage: "square.and.arrow.up")
                        .font(Theme.body(16))
                        .foregroundStyle(Theme.textSecondary)
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
            withAnimation(.easeOut(duration: 0.5).delay(0.9)) { showRoast = true }
        }
    }
}
