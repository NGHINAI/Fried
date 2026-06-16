import SwiftUI
import Charts

/// The main app after onboarding — a 3-tab shell.
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

// MARK: - Today (the living brain dashboard)

struct TodayView: View {
    @EnvironmentObject var app: AppState
    @EnvironmentObject var history: HistoryStore
    @EnvironmentObject var store: Store
    @EnvironmentObject var challenge: ChallengeStore
    @EnvironmentObject var brain: BrainState
    @EnvironmentObject var reportStore: ReportStore
    @State private var analysis: FriedAnalysis?
    @State private var plan: DefryPlan?

    private var score: FriedScore { app.result ?? FriedScore(value: 0, tier: .crispMind) }
    private var brainAge: Int {
        BrainAgeEngine.brainAge(realAge: app.age, score: score, reaction: app.reaction, freshness: brain.freshness)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                header
                brainHero
                brainAgeCard
                reportCard
                if store.hasAccess {
                    tasksCard
                    aiReadCard
                } else {
                    lockedCard
                }
                PrimaryButton(title: "Re-test my brain") {
                    app.jumpToGauntlet = true
                    withAnimation { app.screen = .onboarding }
                }
                .padding(.top, 4)
                Text("For entertainment only — a playful vibe check. Brain age, scores & reports are made-up fun, not a measurement of your health, focus, or intelligence.")
                    .font(.system(size: 11)).foregroundStyle(Theme.textSecondary.opacity(0.55))
                    .multilineTextAlignment(.center).padding(.horizontal, 14).padding(.top, 10)
            }
            .padding(.horizontal, Theme.pad).padding(.top, 60).padding(.bottom, 40)
        }
        .scrollIndicators(.hidden)
        .task {
            if ProcessInfo.processInfo.environment["FRIED_PREVIEW_SCREEN"] == "home" {
                brain.registerScore(score.value)
            }
            history.record(score.value)
            plan = PlanEngine.plan(score: score, quiz: app.quiz, reaction: app.reaction)
            await reportStore.ensure(reportContext())
            analysis = await AnalysisEngine.analyze(score: score, quiz: app.quiz, reaction: app.reaction)
        }
    }

    private func reportContext() -> ReportContext {
        let p = plan ?? PlanEngine.plan(score: score, quiz: app.quiz, reaction: app.reaction)
        let wd = Calendar.current.component(.weekday, from: Date())
        let seed = Calendar.current.ordinality(of: .day, in: .era, for: Date()) ?? 0
        return ReportContext(score: score, realAge: app.age, brainAge: brainAge, freshness: brain.freshness,
                             streak: history.streak, reaction: app.reaction, topLeak: p.leaks.first,
                             weekday: wd, daySeed: seed)
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Your brain").font(Theme.title(26)).foregroundStyle(Theme.textPrimary)
                Text(Date().formatted(.dateTime.weekday(.wide).month().day()))
                    .font(Theme.label(13)).foregroundStyle(Theme.textSecondary)
            }
            Spacer()
            HStack(spacing: 5) {
                Text("🔥").font(.system(size: 15))
                Text("\(history.streak)").font(Theme.body(17)).fontWeight(.semibold).foregroundStyle(Theme.textPrimary)
            }
            .padding(.horizontal, 14).padding(.vertical, 9).friedGlass(cornerRadius: 16)
        }
    }

    // The living brain — FREE (the insecurity hook)
    private var brainHero: some View {
        let barColor = brain.freshness > 60 ? Theme.mint : (brain.freshness > 35 ? Theme.amber : Theme.ember)
        return GlassCard {
            VStack(spacing: 14) {
                EggMascot(mood: .forFreshness(brain.freshness), friedLevel: brain.friedLevel, size: 132)
                    .padding(.top, 4)
                    .animation(.easeInOut(duration: 0.6), value: brain.freshness)
                Text("\(brain.friedPercent)% fried · \(brain.label)")
                    .font(Theme.title(22)).foregroundStyle(Theme.textPrimary)
                GeometryReader { g in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.white.opacity(0.08))
                        Capsule().fill(barColor)
                            .frame(width: max(10, g.size.width * brain.freshness / 100))
                            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: brain.freshness)
                    }
                }
                .frame(height: 8).padding(.horizontal, 2)
                Text(brain.freshness < 40
                     ? "Your brain is frying — cool it down below."
                     : "Keep it fresh. It fries a little more every day you skip.")
                    .font(Theme.body(14)).foregroundStyle(Theme.textSecondary).multilineTextAlignment(.center)
            }
            .padding(22).frame(maxWidth: .infinity)
        }
    }

    // Brain Age — FREE (the insecurity hook)
    private var brainAgeCard: some View {
        GlassCard {
            HStack(spacing: 18) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("BRAIN AGE").font(Theme.label(12)).tracking(1.3).foregroundStyle(Theme.textSecondary)
                    Text("\(brainAge)").font(Theme.score(54)).foregroundStyle(Theme.gradient(for: score.tier))
                }
                Rectangle().fill(Theme.hairline).frame(width: 1, height: 58)
                VStack(alignment: .leading, spacing: 4) {
                    Text("You're \(app.age)").font(Theme.body(16)).foregroundStyle(Theme.textPrimary)
                    Text(BrainAgeEngine.gapLine(realAge: app.age, brainAge: brainAge))
                        .font(Theme.label(13)).foregroundStyle(Theme.amber)
                }
                Spacer(minLength: 0)
            }
            .padding(20).frame(maxWidth: .infinity)
        }
    }

    // Daily Brain Report — the AI dopamine. Headline+risk free, full report paid.
    private var reportCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 7) {
                    Image(systemName: "sparkles").font(.system(size: 13, weight: .bold)).foregroundStyle(Theme.amber)
                    Text("TODAY'S BRAIN REPORT").font(Theme.label(12)).tracking(1.3).foregroundStyle(Theme.textSecondary)
                    Spacer()
                    if let r = reportStore.report { riskPill(r.risk) }
                }
                if let r = reportStore.report {
                    Text(r.headline).font(Theme.title(20)).foregroundStyle(Theme.textPrimary)
                    if store.hasAccess {
                        Text(r.reading).font(Theme.body(15)).foregroundStyle(Theme.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "target").font(.system(size: 13, weight: .bold)).foregroundStyle(Theme.amber)
                            Text("Today's mission — \(r.mission)").font(Theme.body(14)).foregroundStyle(Theme.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.top, 2)
                    } else {
                        ZStack {
                            Text(r.reading).font(Theme.body(15)).foregroundStyle(Theme.textSecondary)
                                .lineLimit(2).blur(radius: 5)
                            Text("🔒 Unlock today's full report + mission")
                                .font(Theme.label(13)).foregroundStyle(Theme.amber)
                        }
                    }
                } else {
                    Text("Reading your brain…").font(Theme.body(15)).foregroundStyle(Theme.textSecondary)
                }
            }
            .padding(20).frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func riskPill(_ risk: String) -> some View {
        let c: Color = risk == "High" ? Theme.ember : (risk == "Medium" ? Theme.amber : Theme.mint)
        return Text("\(risk) risk").font(Theme.label(11)).foregroundStyle(c)
            .padding(.horizontal, 10).padding(.vertical, 5)
            .background(c.opacity(0.13), in: Capsule())
    }

    // De-fry tasks that COOL the brain — PAID (the care loop)
    private var tasksCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Image(systemName: "checklist").font(.system(size: 13, weight: .bold)).foregroundStyle(Theme.amber)
                    Text("COOL YOUR BRAIN DOWN").font(Theme.label(12)).tracking(1.3).foregroundStyle(Theme.textSecondary)
                    Spacer()
                    if let plan {
                        Text("\(challenge.completed(of: plan.steps.count))/\(plan.steps.count)")
                            .font(Theme.label(12)).foregroundStyle(Theme.amber)
                    }
                }
                if let plan {
                    ForEach(Array(plan.steps.enumerated()), id: \.offset) { i, step in
                        Button { toggleTask(i) } label: {
                            HStack(alignment: .top, spacing: 11) {
                                Image(systemName: challenge.isDone(i) ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 21))
                                    .foregroundStyle(challenge.isDone(i) ? Theme.mint : Theme.textSecondary.opacity(0.55))
                                Text(step).font(Theme.body(15))
                                    .foregroundStyle(challenge.isDone(i) ? Theme.textSecondary : Theme.textPrimary)
                                    .strikethrough(challenge.isDone(i))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text("+7").font(Theme.label(12)).foregroundStyle(Theme.mint)
                                    .opacity(challenge.isDone(i) ? 0.35 : 1)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                Text("Each one cools your brain. Skip a day and it fries again.")
                    .font(Theme.label(12)).foregroundStyle(Theme.textSecondary)
            }
            .padding(20).frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func toggleTask(_ i: Int) {
        let wasDone = challenge.isDone(i)
        challenge.toggle(i)
        brain.recover(wasDone ? -7 : 7)
    }

    private var aiReadCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 7) {
                    Image(systemName: "brain").font(.system(size: 13, weight: .bold)).foregroundStyle(Theme.amber)
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

    private var lockedCard: some View {
        Button {
            app.paywallReturn = .home
            withAnimation { app.screen = .paywall }
        } label: {
            GlassCard {
                VStack(spacing: 10) {
                    Image(systemName: "lock.fill").font(.system(size: 26)).foregroundStyle(Theme.amber)
                    Text("Cool your brain down").font(Theme.title(20)).foregroundStyle(Theme.textPrimary)
                    Text("Unlock your full daily report, the missions that de-fry your brain, the AI's read, and tracking.")
                        .font(Theme.body(14)).foregroundStyle(Theme.textSecondary).multilineTextAlignment(.center)
                    Text("\(store.fullPriceText) once · no subscription").font(Theme.body(15)).fontWeight(.semibold)
                        .foregroundStyle(Theme.amber).padding(.top, 2)
                }
                .padding(24).frame(maxWidth: .infinity)
            }
        }
        .buttonStyle(.plain)
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
    @AppStorage("fried.notif.on") private var notifOn = false

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
                                Text("Unlock Fried").font(Theme.title(22)).foregroundStyle(Theme.textPrimary)
                                Text("Daily report, de-fry missions, AI read & tracking").font(Theme.label(13))
                                    .foregroundStyle(Theme.textSecondary).multilineTextAlignment(.center)
                                Text("\(store.fullPriceText) once · no subscription").font(Theme.body(15)).fontWeight(.semibold)
                                    .foregroundStyle(Theme.amber).padding(.top, 4)
                            }.padding(22).frame(maxWidth: .infinity)
                        }
                    }.buttonStyle(.plain)
                }

                GlassCard {
                    Toggle(isOn: $notifOn) {
                        HStack(spacing: 14) {
                            Image(systemName: "bell.fill").font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(Theme.amber).frame(width: 24)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Daily reminder").font(Theme.body(16)).foregroundStyle(Theme.textPrimary)
                                Text("Before your brain fries again").font(Theme.label(12)).foregroundStyle(Theme.textSecondary)
                            }
                        }
                    }
                    .tint(Theme.amber)
                    .padding(.horizontal, 18).padding(.vertical, 12)
                    .onChange(of: notifOn) { _, on in
                        Task {
                            if on {
                                let ok = await NotificationManager.requestAndSchedule()
                                if !ok { notifOn = false }
                            } else {
                                NotificationManager.cancel()
                            }
                        }
                    }
                }

                GlassCard {
                    VStack(spacing: 0) {
                        row("Restore purchases", "arrow.clockwise") { Task { await store.restore() } }
                        divider
                        link("Terms of use", "doc.text", "https://nghinai.github.io/Fried/terms.html")
                        divider
                        link("Privacy policy", "hand.raised", "https://nghinai.github.io/Fried/privacy.html")
                        divider
                        link("Contact", "envelope", "mailto:hello@fried.app")
                    }.padding(.vertical, 4)
                }

                Text("Fried is for entertainment only — a playful vibe check, not a measurement of your health, focus, or intelligence.")
                    .font(.system(size: 11)).foregroundStyle(Theme.textSecondary.opacity(0.6))
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
