import SwiftUI

/// The front door. The number is the WOW (counts up, confetti). Then the THREAT
/// lands: where you rank, the recoverable points you're LOSING, and the five
/// things frying you — named but locked. You learn THAT you're fried for free;
/// you pay $5 to learn WHY and HOW to fix it. (Zeigarnik open loop + loss frame
/// + social comparison — all research-backed.)
struct RevealView: View {
    @EnvironmentObject var app: AppState
    @EnvironmentObject var store: Store
    @EnvironmentObject var brain: BrainState
    @State private var roast = ""
    @State private var showRoast = false
    @State private var shareImage: Image?
    @State private var confetti = false
    @State private var celebrate = false
    @State private var revealThreat = false

    private var score: FriedScore { app.result ?? FriedScore(value: 0, tier: .crispMind) }
    private var breakdown: BrainBreakdown {
        BrainBreakdownEngine.make(quiz: app.quiz, reaction: app.reaction, screenTime: nil,
                                  overall: score.value, age: app.age)
    }

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 18) {
                    Text("YOUR FRIED SCORE").font(Theme.label(13)).tracking(2.5)
                        .foregroundStyle(Theme.textSecondary).padding(.top, 18)
                    ScoreDial(score: score.value, tier: score.tier)
                        .scaleEffect(celebrate ? 1 : 0.85)
                        .animation(.spring(response: 0.6, dampingFraction: 0.6), value: celebrate)
                    Text("\(score.tier.emoji)  \(score.tier.title)")
                        .font(Theme.title(28)).foregroundStyle(Theme.textPrimary)
                    percentileLine

                    if revealThreat {
                        gapCard
                        lockedBreakdown
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    if showRoast, !roast.isEmpty {
                        GlassCard {
                            Text(roast).font(Theme.body(17)).foregroundStyle(Theme.textPrimary)
                                .multilineTextAlignment(.center).padding(20).frame(maxWidth: .infinity)
                        }
                    }
                    shareRow
                    Text("For entertainment only — a playful vibe check, not a measurement of your health, focus, or intelligence.")
                        .font(.system(size: 11)).foregroundStyle(Theme.textSecondary.opacity(0.6))
                        .multilineTextAlignment(.center).padding(.horizontal, 22).padding(.top, 2)
                }
                .padding(.horizontal, Theme.pad).padding(.bottom, 150)
            }
            .scrollIndicators(.hidden)
            ConfettiView(burst: confetti).ignoresSafeArea().allowsHitTesting(false)
            #if DEBUG
            if ProcessInfo.processInfo.environment["FRIED_PREVIEW_SHARECARD"] == "1", let shareImage {
                Color.black.ignoresSafeArea()
                shareImage.resizable().aspectRatio(contentMode: .fit).ignoresSafeArea()
            }
            #endif
        }
        .safeAreaInset(edge: .bottom) { ctaBar }
        .task {
            brain.registerScore(score.value)
            roast = await RoastEngine.roast(for: score)
            shareImage = ShareCard.image(score: score, breakdown: breakdown, roast: roast)
            withAnimation(.easeOut(duration: 0.5).delay(0.9)) { showRoast = true }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.85).delay(1.3)) { revealThreat = true }
        }
        .onAppear {
            celebrate = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { confetti = true }
        }
        .sensoryFeedback(.success, trigger: confetti)
    }

    // FREE — the shareable social-comparison sting (red if below the pack, green if ahead)
    private var percentileLine: some View {
        let p = breakdown.percentile
        return Text("More fried than \(p)% of people your age")
            .font(Theme.title(17)).foregroundStyle(p >= 50 ? Theme.danger : Theme.recovery)
            .multilineTextAlignment(.center)
    }

    // FREE — the loss frame: current → recoverable, and the points you're sitting on
    private var gapCard: some View {
        GlassCard {
            VStack(spacing: 12) {
                HStack(alignment: .center, spacing: 8) {
                    pole(value: score.value, label: "FRIED NOW", color: Theme.danger)
                    Image(systemName: "arrow.right").font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Theme.textSecondary)
                    pole(value: breakdown.potential, label: "RECOVERABLE TO", color: Theme.recovery)
                }
                (Text("You're sitting on a ")
                 + Text("\(breakdown.gap)-point").foregroundColor(Theme.recovery).bold()
                 + Text(" loss — that's how much of your brain you could claw back."))
                    .font(Theme.body(14)).foregroundStyle(Theme.textPrimary)
                    .multilineTextAlignment(.center).fixedSize(horizontal: false, vertical: true)
            }
            .padding(20).frame(maxWidth: .infinity)
        }
    }
    private func pole(value: Int, label: String, color: Color) -> some View {
        VStack(spacing: 3) {
            Text("\(value)").font(Theme.hero(44)).foregroundStyle(color)
            Text(label).font(Theme.label(10)).tracking(1.3).foregroundStyle(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    // THE OPEN LOOP — names your #1 leak free; locks the why + the other four + the fix
    private var lockedBreakdown: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 13) {
                HStack {
                    Image(systemName: "lock.fill").font(.system(size: 12, weight: .bold)).foregroundStyle(Theme.amber)
                    Text("WHAT'S FRYING YOU").font(Theme.label(12)).tracking(1.3).foregroundStyle(Theme.textSecondary)
                    Spacer()
                    Text("1 tap away").font(Theme.label(12)).foregroundStyle(Theme.amber)
                }
                (Text("Your #1 leak: ")
                 + Text(breakdown.topLeak.label).foregroundColor(Theme.danger).bold())
                    .font(Theme.body(16)).foregroundStyle(Theme.textPrimary)
                Text(breakdown.topLeak.blurb).font(Theme.body(14)).foregroundStyle(Theme.textSecondary)
                    .lineLimit(2).blur(radius: 6).overlay(alignment: .leading) {
                        Text("●●●●● ●●●● ●●●●●●● ●●● ●●●●").font(Theme.body(14)).foregroundStyle(.clear)
                    }
                Divider().overlay(Theme.hairline)
                ForEach(breakdown.dimensions) { dim in
                    HStack {
                        Text(dim.label).font(Theme.body(15)).foregroundStyle(Theme.textPrimary)
                        Spacer()
                        Text("\(dim.fried)").font(Theme.score(16))
                            .foregroundStyle(dim.fried >= 55 ? Theme.danger : Theme.recovery)
                            .blur(radius: 6)
                    }
                }
            }
            .padding(20).frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var shareRow: some View {
        Group {
            if let shareImage {
                ShareLink(item: shareImage,
                          message: Text("How fried is your brain? I scored \(score.value) 🍳 fried.app"),
                          preview: SharePreview("My Fried Score", image: shareImage)) {
                    Label("Share my score", systemImage: "square.and.arrow.up")
                        .font(Theme.body(15)).foregroundStyle(Theme.textSecondary)
                }
            }
        }
    }

    private var ctaBar: some View {
        VStack(spacing: 8) {
            if store.hasAccess {
                PrimaryButton(title: "See my full breakdown") { withAnimation { app.screen = .home } }
            } else {
                PrimaryButton(title: "Unlock what's frying me",
                              subtitle: "\(store.fullPriceText) once · your breakdown, #1 leak & fix") {
                    app.paywallReturn = .reveal
                    withAnimation { app.screen = .paywall }
                }
            }
        }
        .padding(.horizontal, Theme.pad).padding(.top, 12).padding(.bottom, 8)
        .background(.ultraThinMaterial)
    }
}
