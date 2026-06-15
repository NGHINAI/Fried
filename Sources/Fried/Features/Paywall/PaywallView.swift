import SwiftUI

/// Sells the transformation (a focus reset), not the score. Closing it shows a
/// clear, distinct discount offer (50% → 80%) with an explicit way out — no more
/// "the X does nothing" confusion.
struct PaywallView: View {
    @EnvironmentObject var app: AppState
    @EnvironmentObject var store: Store
    @State private var working = false
    @State private var exitStage = 0   // 0 none · 1 = 50% offer · 2 = 80% offer

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
                GlassCard {
                    VStack(spacing: 18) {
                        ForEach(perks, id: \.0) { p in perkRow(icon: p.0, title: p.1, sub: p.2) }
                    }
                    .padding(22).frame(maxWidth: .infinity)
                }
                planPeek
            }
            .padding(.horizontal, Theme.pad).padding(.top, 56).padding(.bottom, 230)
        }
        .scrollIndicators(.hidden)
        .safeAreaInset(edge: .bottom) { bottomBar }
        .overlay(alignment: .topTrailing) { closeButton }
        .overlay { if exitStage > 0 { exitOffer } }
        .onAppear {
            if let t = ProcessInfo.processInfo.environment["FRIED_PREVIEW_PAYTIER"], let v = Int(t) { exitStage = v }
        }
    }

    private var header: some View {
        VStack(spacing: 12) {
            Text(score.tier.emoji).font(.system(size: 50))
            Text("Your focus is fixable.")
                .font(Theme.title(31)).foregroundStyle(Theme.textPrimary).multilineTextAlignment(.center)
            Text("Unlock your full report **and** a personalized de-fry plan built from your answers.")
                .font(Theme.body(15)).foregroundStyle(Theme.textSecondary).multilineTextAlignment(.center)
        }
    }

    private var planPeek: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 7) {
                    Image(systemName: "checklist").font(.system(size: 13, weight: .bold)).foregroundStyle(Theme.amber)
                    Text("A PEEK AT YOUR PLAN").font(Theme.label(12)).tracking(1.3).foregroundStyle(Theme.textSecondary)
                }
                let plan = PlanEngine.plan(score: score, quiz: app.quiz, reaction: app.reaction)
                Text(plan.diagnosis).font(Theme.body(15)).foregroundStyle(Theme.textPrimary)
                ZStack {
                    VStack(alignment: .leading, spacing: 9) {
                        ForEach(Array(plan.steps.prefix(3).enumerated()), id: \.offset) { i, step in
                            HStack(alignment: .top, spacing: 10) {
                                Text("\(i + 1)").font(Theme.label(12)).foregroundStyle(.black)
                                    .frame(width: 22, height: 22).background(Theme.heatGradient, in: Circle())
                                Text(step).font(Theme.body(14)).foregroundStyle(Theme.textPrimary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                    .blur(radius: 6)
                    .overlay(
                        VStack(spacing: 4) {
                            Image(systemName: "lock.fill").foregroundStyle(Theme.amber)
                            Text("Unlock to see your full plan").font(Theme.label(13)).foregroundStyle(Theme.textPrimary)
                        }
                    )
                }
            }
            .padding(20).frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func perkRow(icon: String, title: String, sub: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon).font(.system(size: 16, weight: .bold)).foregroundStyle(.black)
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
        Button { withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { handleClose() } } label: {
            Image(systemName: "xmark").font(.system(size: 14, weight: .bold))
                .foregroundStyle(Theme.textSecondary)
                .frame(width: 34, height: 34).friedGlass(cornerRadius: 17)
        }
        .buttonStyle(.plain).padding(.trailing, Theme.pad).padding(.top, 8)
    }

    private func handleClose() {
        if exitStage == 0 { exitStage = 1 } else { dismiss() }
    }
    private func dismiss() { withAnimation { app.screen = app.paywallReturn } }

    private var bottomBar: some View {
        VStack(spacing: 12) {
            PrimaryButton(title: working ? "…" : "Unlock everything",
                          subtitle: "\(store.fullPriceText) once · no subscription, ever") {
                Task {
                    working = true
                    _ = await store.purchase(.full)
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
                .foregroundStyle(Theme.textSecondary.opacity(0.6)).multilineTextAlignment(.center).padding(.horizontal, 12)
        }
        .padding(.horizontal, Theme.pad).padding(.top, 16).padding(.bottom, 8)
        .background(.ultraThinMaterial)
    }

    // MARK: discount-on-exit (distinct, with a real way out)
    private var offerTier: Store.Discount { exitStage == 1 ? .off50 : .off80 }

    private var exitOffer: some View {
        ZStack {
            Color.black.opacity(0.78).ignoresSafeArea()
            VStack(spacing: 16) {
                Text(exitStage == 1 ? "🎁" : "⏰").font(.system(size: 54))
                Text(exitStage == 1 ? "Wait — 50% off,\njust for you" : "Last chance:\n80% off")
                    .font(Theme.title(27)).foregroundStyle(Theme.textPrimary).multilineTextAlignment(.center)
                HStack(spacing: 10) {
                    Text(store.fullPriceText).font(Theme.body(18)).strikethrough().foregroundStyle(Theme.textSecondary)
                    Text(store.priceText(offerTier)).font(Theme.score(40)).foregroundStyle(Theme.gradient(for: .lightlyToasted))
                }
                Text("Unlock everything, forever. No subscription.")
                    .font(Theme.body(14)).foregroundStyle(Theme.textSecondary)
                PrimaryButton(title: working ? "…" : "Claim \(exitStage == 1 ? "50" : "80")% off",
                              subtitle: "\(store.priceText(offerTier)) once") {
                    Task {
                        working = true
                        _ = await store.purchase(offerTier)
                        working = false
                        if store.hasAccess { withAnimation { app.screen = .home } }
                    }
                }
                Button(exitStage == 1 ? "No thanks" : "No thanks, close the app") {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        if exitStage == 1 { exitStage = 2 } else { dismiss() }
                    }
                }
                .font(Theme.body(15)).foregroundStyle(Theme.textSecondary).padding(.top, 4)
            }
            .padding(28)
            .friedGlass(cornerRadius: 28)
            .padding(.horizontal, 26)
        }
        .transition(.opacity)
    }
}
