import SwiftUI

/// Sells the transformation (a focus reset), not the score. Closing it doesn't
/// quit — it steps down the discount ladder: full → 50% off → 80% off → exit.
struct PaywallView: View {
    @EnvironmentObject var app: AppState
    @EnvironmentObject var store: Store
    @State private var tier: Store.Discount = .full
    @State private var working = false

    private var score: FriedScore { app.result ?? FriedScore(value: 0, tier: .crispMind) }

    private let perks = [
        ("doc.text.magnifyingglass", "Your full report", "Clear score, breakdown & the AI's read on you"),
        ("checklist", "A personalized de-fry plan", "Specific steps built from your own answers"),
        ("chart.line.downtrend.xyaxis", "Watch it drop", "Daily score, streak & your 7-day trend"),
        ("flame.fill", "Daily roasts + share cards", "Fresh verdicts & flex cards for friends")
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                header
                if let badge = tier.badge {
                    Text("🔥 \(badge) — just for you")
                        .font(Theme.label(14)).foregroundStyle(.black)
                        .padding(.horizontal, 16).padding(.vertical, 9)
                        .background(Theme.heatGradientH, in: Capsule())
                        .transition(.scale.combined(with: .opacity))
                }
                GlassCard {
                    VStack(spacing: 18) {
                        ForEach(perks, id: \.0) { p in perkRow(icon: p.0, title: p.1, sub: p.2) }
                    }
                    .padding(22).frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, Theme.pad).padding(.top, 56).padding(.bottom, 250)
        }
        .scrollIndicators(.hidden)
        .safeAreaInset(edge: .bottom) { bottomBar }
        .overlay(alignment: .topTrailing) { closeButton }
        .onAppear {
            if let t = ProcessInfo.processInfo.environment["FRIED_PREVIEW_PAYTIER"],
               let v = Int(t), let d = Store.Discount(rawValue: v) { tier = d }
        }
    }

    private var header: some View {
        VStack(spacing: 12) {
            Text(score.tier.emoji).font(.system(size: 50))
            Text("Your focus is fixable.")
                .font(Theme.title(31)).foregroundStyle(Theme.textPrimary)
                .multilineTextAlignment(.center)
            Text("Unlock your full report **and** a personalized de-fry plan built from your answers.")
                .font(Theme.body(15)).foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
        }
    }

    private func perkRow(icon: String, title: String, sub: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .bold)).foregroundStyle(.black)
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
        Button { handleClose() } label: {
            Image(systemName: "xmark").font(.system(size: 14, weight: .bold))
                .foregroundStyle(Theme.textSecondary)
                .frame(width: 34, height: 34).friedGlass(cornerRadius: 17)
        }
        .buttonStyle(.plain).padding(.trailing, Theme.pad).padding(.top, 8)
    }

    /// Closing steps DOWN the discount ladder before it actually dismisses.
    private func handleClose() {
        if let next = tier.next {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) { tier = next }
        } else {
            withAnimation { app.screen = app.paywallReturn }
        }
    }

    private var priceSubtitle: String {
        tier == .full
            ? "\(store.priceText(.full)) once · no subscription, ever"
            : "\(store.priceText(tier)) once · was \(store.priceText(.full))"
    }

    private var bottomBar: some View {
        VStack(spacing: 12) {
            PrimaryButton(title: working ? "…" : "Unlock everything", subtitle: priceSubtitle) {
                Task {
                    working = true
                    _ = await store.purchase(tier)
                    working = false
                    if store.hasAccess { withAnimation { app.screen = .home } }
                }
            }
            ShareLink(item: URL(string: "https://fried.app")!,
                      message: Text("How fried is your brain? I scored \(score.value) 🍳 Beat me:")) {
                Text("…or invite 3 friends to unlock it free")
                    .font(Theme.body(15)).fontWeight(.semibold).foregroundStyle(Theme.amber)
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
                .multilineTextAlignment(.center).padding(.horizontal, 12)
        }
        .padding(.horizontal, Theme.pad).padding(.top, 16).padding(.bottom, 8)
        .background(.ultraThinMaterial)
    }
}
