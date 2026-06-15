import SwiftUI
import Charts

/// The main app after onboarding — a simple 3-tab shell (iOS 26 gives it a
/// Liquid Glass tab bar automatically).
struct MainTabView: View {
    @State private var sel = 0
    var body: some View {
        TabView(selection: $sel) {
            TodayView().tag(0).tabItem { Label("Today", systemImage: "flame.fill") }
            TrendsView().tag(1).tabItem { Label("Trends", systemImage: "chart.bar.fill") }
            ProfileView().tag(2).tabItem { Label("You", systemImage: "person.fill") }
        }
        .tint(Theme.amber)
        .onAppear {
            switch ProcessInfo.processInfo.environment["FRIED_PREVIEW_TAB"] {
            case "trends": sel = 1
            case "you": sel = 2
            default: break
            }
        }
    }
}

// MARK: - Today

struct TodayView: View {
    @EnvironmentObject var app: AppState
    @EnvironmentObject var history: HistoryStore
    @State private var roast = ""
    @State private var analysis: FriedAnalysis?

    private var score: FriedScore { app.result ?? FriedScore(value: 0, tier: .crispMind) }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                header
                scoreCard
                aiReadCard
                breakdownCard
                roastCard
                PrimaryButton(title: "Re-test my reflexes") {
                    app.jumpToGauntlet = true
                    withAnimation { app.screen = .onboarding }
                }
                .padding(.top, 4)
            }
            .padding(.horizontal, Theme.pad)
            .padding(.top, 64)
            .padding(.bottom, 40)
        }
        .scrollIndicators(.hidden)
        .task {
            history.record(score.value)
            roast = await RoastEngine.roast(for: score)
            analysis = await AnalysisEngine.analyze(score: score, quiz: app.quiz, reaction: app.reaction)
        }
    }

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Your brain today").font(Theme.title(26)).foregroundStyle(Theme.textPrimary)
                Text(Date().formatted(.dateTime.weekday(.wide).month().day()))
                    .font(Theme.label(13)).foregroundStyle(Theme.textSecondary)
            }
            Spacer()
            HStack(spacing: 5) {
                Text("🔥").font(.system(size: 15))
                Text("\(history.streak)").font(Theme.body(17)).fontWeight(.bold).foregroundStyle(Theme.textPrimary)
            }
            .padding(.horizontal, 14).padding(.vertical, 9)
            .friedGlass(cornerRadius: 16)
        }
    }

    private var scoreCard: some View {
        GlassCard {
            HStack(spacing: 18) {
                ZStack {
                    Circle().stroke(.white.opacity(0.08), lineWidth: 10)
                    Circle().trim(from: 0, to: Double(score.value) / 100)
                        .stroke(Theme.gradient(for: score.tier), style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    Text("\(score.value)").font(Theme.score(34)).foregroundStyle(Theme.gradient(for: score.tier))
                }
                .frame(width: 92, height: 92)
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(score.tier.emoji) \(score.tier.title)").font(Theme.title(22)).foregroundStyle(Theme.textPrimary)
                    Text("Today's fried score").font(Theme.label(13)).foregroundStyle(Theme.textSecondary)
                }
                Spacer(minLength: 0)
            }
            .padding(20).frame(maxWidth: .infinity)
        }
    }

    private var aiReadCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 7) {
                    Image(systemName: "sparkles").font(.system(size: 13, weight: .bold)).foregroundStyle(Theme.amber)
                    Text("THE AI'S READ ON YOU").font(Theme.label(12)).tracking(1.3).foregroundStyle(Theme.textSecondary)
                }
                Text(analysis?.summary ?? "Reading your data…")
                    .font(Theme.body(16)).foregroundStyle(Theme.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if let insights = analysis?.insights, !insights.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(insights, id: \.self) { line in
                            HStack(alignment: .top, spacing: 8) {
                                Text("•").foregroundStyle(Theme.amber)
                                Text(line).font(Theme.body(14)).foregroundStyle(Theme.textSecondary)
                            }
                        }
                    }
                    .padding(.top, 2)
                }
            }
            .padding(20).frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var breakdownCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("THE BREAKDOWN").font(Theme.label(12)).tracking(1.5).foregroundStyle(Theme.textSecondary)
                ForEach(subScores, id: \.0) { item in bar(item.0, item.1) }
            }
            .padding(20).frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var roastCard: some View {
        GlassCard {
            HStack(alignment: .top, spacing: 12) {
                Text("🔥").font(.system(size: 22))
                Text(roast.isEmpty ? " " : roast).font(Theme.body(16)).foregroundStyle(Theme.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(20)
        }
    }

    private func bar(_ label: String, _ val: Int) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack {
                Text(label).font(Theme.body(15)).foregroundStyle(Theme.textPrimary)
                Spacer()
                Text("\(val)").font(Theme.label(14)).foregroundStyle(Theme.textSecondary)
            }
            GeometryReader { g in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.08))
                    Capsule().fill(Theme.heatGradientH).frame(width: max(8, g.size.width * Double(val) / 100))
                }
            }
            .frame(height: 8)
        }
    }

    private var subScores: [(String, Int)] {
        let base = score.value
        if let q = app.quiz, let r = app.reaction {
            return [
                ("Scroll habits", Int(ScoringEngine.quizScore(q).rounded())),
                ("Reflex lag", Int(ScoringEngine.reactionScore(r).rounded())),
                ("Focus drift", Int(min(100, max(0, r.lapseVariance * 100)).rounded()))
            ]
        }
        return [("Scroll habits", min(100, base + 6)), ("Reflex lag", max(0, base - 8)), ("Focus drift", min(100, base + 2))]
    }
}

// MARK: - Trends

struct TrendsView: View {
    @EnvironmentObject var history: HistoryStore

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Your trend")
                    .font(Theme.title(28)).foregroundStyle(Theme.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                GlassCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("LAST 7 DAYS").font(Theme.label(12)).tracking(1.5).foregroundStyle(Theme.textSecondary)
                        Chart(history.last7) { d in
                            BarMark(x: .value("Day", d.date, unit: .day),
                                    y: .value("Score", d.value), width: .ratio(0.55))
                                .foregroundStyle(Theme.heatGradient).cornerRadius(5)
                        }
                        .chartYScale(domain: 0...100)
                        .chartXAxis { AxisMarks(values: .stride(by: .day)) {
                            AxisValueLabel(format: .dateTime.weekday(.narrow)).foregroundStyle(Theme.textSecondary)
                        } }
                        .chartYAxis(.hidden)
                        .frame(height: 150)
                        if let delta = weekDelta {
                            Text(delta.text).font(Theme.body(14)).fontWeight(.semibold)
                                .foregroundStyle(delta.good ? Theme.mint : Theme.amber)
                        }
                    }
                    .padding(20).frame(maxWidth: .infinity, alignment: .leading)
                }
                if history.days.isEmpty {
                    Text("Take the test daily to build your trend.")
                        .font(Theme.body(15)).foregroundStyle(Theme.textSecondary).padding(.top, 8)
                }
            }
            .padding(.horizontal, Theme.pad).padding(.top, 64).padding(.bottom, 40)
        }
        .scrollIndicators(.hidden)
        .task { if ProcessInfo.processInfo.environment["FRIED_PREVIEW_SCREEN"] == "home" { history.seedSampleIfEmpty() } }
    }

    private var weekDelta: (text: String, good: Bool)? {
        let d = history.last7
        guard d.count >= 2, let first = d.first, let last = d.last else { return nil }
        let diff = last.value - first.value
        if diff == 0 { return ("No change this week", true) }
        return diff < 0 ? ("↓ \(abs(diff)) less fried this week", true) : ("↑ \(diff) more fried this week", false)
    }
}

// MARK: - You / Profile

struct ProfileView: View {
    @EnvironmentObject var app: AppState
    @EnvironmentObject var store: Store

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("You")
                    .font(Theme.title(28)).foregroundStyle(Theme.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if store.hasAccess {
                    GlassCard {
                        HStack(spacing: 12) {
                            Image(systemName: "checkmark.seal.fill").font(.system(size: 22)).foregroundStyle(Theme.amber)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Fried Pro").font(Theme.title(20)).foregroundStyle(Theme.textPrimary)
                                Text("Unlocked forever. Nice.").font(Theme.label(13)).foregroundStyle(Theme.textSecondary)
                            }
                            Spacer()
                        }.padding(20).frame(maxWidth: .infinity)
                    }
                } else {
                    Button {
                        app.paywallReturn = .home
                        withAnimation { app.screen = .paywall }
                    } label: {
                        GlassCard {
                            VStack(spacing: 8) {
                                Text("🔓 Unlock Fried").font(Theme.title(22)).foregroundStyle(Theme.textPrimary)
                                Text("Full breakdown, daily roasts, share cards & more").font(Theme.label(13))
                                    .foregroundStyle(Theme.textSecondary).multilineTextAlignment(.center)
                                Text("\(store.priceText) once · no subscription").font(Theme.body(15)).fontWeight(.bold)
                                    .foregroundStyle(Theme.amber).padding(.top, 4)
                            }.padding(22).frame(maxWidth: .infinity)
                        }
                    }.buttonStyle(.plain)
                }

                GlassCard {
                    VStack(spacing: 0) {
                        row("Restore purchases", "arrow.clockwise") { Task { await store.restore() } }
                        divider
                        link("Terms of use", "doc.text", "https://fried.app/terms")
                        divider
                        link("Privacy policy", "hand.raised", "https://fried.app/privacy")
                        divider
                        link("Contact", "envelope", "mailto:hello@fried.app")
                    }.padding(.vertical, 4)
                }

                Text("Fried is for entertainment only — a playful vibe check, not a measurement of your health, focus, or intelligence.")
                    .font(.system(size: 11, design: .rounded)).foregroundStyle(Theme.textSecondary.opacity(0.6))
                    .multilineTextAlignment(.center).padding(.horizontal, 16).padding(.top, 6)
            }
            .padding(.horizontal, Theme.pad).padding(.top, 64).padding(.bottom, 40)
        }
        .scrollIndicators(.hidden)
    }

    private var divider: some View { Rectangle().fill(Theme.hairline).frame(height: 1).padding(.leading, 52) }

    private func row(_ title: String, _ icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) { rowLabel(title, icon) }.buttonStyle(.plain)
    }
    private func link(_ title: String, _ icon: String, _ url: String) -> some View {
        Link(destination: URL(string: url)!) { rowLabel(title, icon) }
    }
    private func rowLabel(_ title: String, _ icon: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon).font(.system(size: 15, weight: .semibold)).foregroundStyle(Theme.amber).frame(width: 24)
            Text(title).font(Theme.body(16)).foregroundStyle(Theme.textPrimary)
            Spacer()
            Image(systemName: "chevron.right").font(.system(size: 12, weight: .bold)).foregroundStyle(Theme.textSecondary.opacity(0.5))
        }
        .padding(.horizontal, 18).padding(.vertical, 15)
    }
}
