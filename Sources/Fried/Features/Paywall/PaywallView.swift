import SwiftUI

/// The conversion screen (Cal-AI structure): result-tied headline → value stack →
/// price + soft CTA → the viral "invite to unlock" alternative → restore/legal.
struct PaywallView: View {
    @EnvironmentObject var app: AppState
    @EnvironmentObject var store: Store
    @State private var working = false

    private var score: FriedScore { app.result ?? FriedScore(value: 0, tier: .crispMind) }

    private let perks = [
        ("chart.bar.fill", "Your full breakdown", "Reflex speed, scroll habits & doomscroll depth"),
        ("flame.fill", "A fresh roast every day", "New verdicts + unlock every roast pack"),
        ("bolt.heart.fill", "Track your de-fry streak", "Watch your score drop week over week"),
        ("square.and.arrow.up.fill", "Share cards", "Flex (or shame) your score to friends")
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                header
                GlassCard {
                    VStack(spacing: 18) {
                        ForEach(perks, id: \.0) { perk in
                            perkRow(icon: perk.0, title: perk.1, sub: perk.2)
                        }
                    }
                    .padding(22)
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, Theme.pad)
            .padding(.top, 56)
            .padding(.bottom, 250)
        }
        .scrollIndicators(.hidden)
        .safeAreaInset(edge: .bottom) { bottomBar }
        .overlay(alignment: .topTrailing) { closeButton }
    }

    private var header: some View {
        VStack(spacing: 12) {
            Text(score.tier.emoji).font(.system(size: 50))
            Text("Unlock your full\nBrain-Rot Report")
                .font(Theme.title(30)).foregroundStyle(Theme.textPrimary)
                .multilineTextAlignment(.center)
            Text("You scored \(score.value). Here's everything that's cooking.")
                .font(Theme.body(15)).foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
        }
    }

    private func perkRow(icon: String, title: String, sub: String) -> some View {
        HStack(alignment: .center, spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.black)
                .frame(width: 36, height: 36)
                .background(Theme.heatGradient, in: RoundedRectangle(cornerRadius: 11, style: .continuous))
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(Theme.body(16)).fontWeight(.semibold).foregroundStyle(Theme.textPrimary)
                Text(sub).font(Theme.label(12)).foregroundStyle(Theme.textSecondary)
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var closeButton: some View {
        Button { withAnimation { app.screen = .reveal } } label: {
            Image(systemName: "xmark")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Theme.textSecondary)
                .frame(width: 34, height: 34)
                .friedGlass(cornerRadius: 17)
        }
        .buttonStyle(.plain)
        .padding(.trailing, Theme.pad)
        .padding(.top, 8)
    }

    private var bottomBar: some View {
        VStack(spacing: 12) {
            PrimaryButton(title: working ? "…" : "Unlock everything",
                          subtitle: "\(store.priceText) once · no subscription, ever") {
                Task {
                    working = true
                    _ = await store.purchase()
                    working = false
                    if store.hasAccess { withAnimation { app.screen = .home } }
                }
            }

            ShareLink(item: URL(string: "https://fried.app")!,
                      message: Text("How fried is your brain? I scored \(score.value) 🍳 Beat me:")) {
                Text("…or invite 3 friends to unlock it free")
                    .font(Theme.body(15)).fontWeight(.semibold)
                    .foregroundStyle(Theme.amber)
            }
            .simultaneousGesture(TapGesture().onEnded { store.invitedUnlock = true })

            HStack(spacing: 14) {
                Button("Restore") { Task { await store.restore(); if store.hasAccess { app.screen = .home } } }
                Text("·").foregroundStyle(Theme.textSecondary.opacity(0.5))
                Link("Terms", destination: URL(string: "https://fried.app/terms")!)
                Text("·").foregroundStyle(Theme.textSecondary.opacity(0.5))
                Link("Privacy", destination: URL(string: "https://fried.app/privacy")!)
            }
            .font(Theme.label(12)).foregroundStyle(Theme.textSecondary)

            Text("Entertainment only — a playful vibe check, not a measurement of health, focus, or intelligence.")
                .font(.system(size: 10, weight: .regular, design: .rounded))
                .foregroundStyle(Theme.textSecondary.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 12)
        }
        .padding(.horizontal, Theme.pad)
        .padding(.top, 16)
        .padding(.bottom, 8)
        .background(.ultraThinMaterial)
    }
}
