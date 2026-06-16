import SwiftUI
import Charts

/// Shared tab selection so proactive nudges can jump the user to the Yolkie tab.
@MainActor final class TabRouter: ObservableObject { @Published var sel = 0 }

/// The main app after onboarding — a 4-tab shell with Yolkie (the AI) front and centre.
struct MainTabView: View {
    @EnvironmentObject var router: TabRouter
    var body: some View {
        TabView(selection: $router.sel) {
            TodayView().tag(0).tabItem { Label("Today", systemImage: "flame.fill") }
            TrendsView().tag(1).tabItem { Label("Trends", systemImage: "chart.bar.fill") }
            AskView(embedded: true).tag(2).tabItem { Label("Yolkie", systemImage: "sparkles") }
            ProfileView().tag(3).tabItem { Label("You", systemImage: "person.fill") }
        }
        .tint(Theme.amber)
        .onAppear {
            switch ProcessInfo.processInfo.environment["FRIED_PREVIEW_TAB"] {
            case "trends": router.sel = 1
            case "yolkie": router.sel = 2
            case "you": router.sel = 3
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
    @EnvironmentObject var router: TabRouter
    @State private var proactiveLine = ""
    @State private var analysis: FriedAnalysis?
    @State private var plan: DefryPlan?
    @State private var shownFreshness: Double? = nil   // animated display value for the bar/egg
    @State private var showDamage = false              // "while you were gone" loss banner
    @State private var gainPop: Int? = nil             // floating +N on recovery
    @State private var thudTick = 0                    // heavy-haptic trigger (the damage)
    @State private var successTick = 0                 // success-haptic trigger (the repair)
    @State private var showNotifPrime = false          // one-time benefit-first notif priming
    @State private var dismissedMilestone = false      // hide the streak-milestone share banner
    @State private var showGoalSheet = false           // one-time first-session goal pick
    @State private var goalSel = 30

    private var isPreview: Bool { ProcessInfo.processInfo.environment["FRIED_PREVIEW_SCREEN"] != nil }

    /// What the bar/egg actually render. Lags `brain.freshness` so we can animate
    /// it draining (decay) or springing up (recovery). Before the first settle it
    /// shows where you LAST saw it, so the drain starts from the right place.
    private var displayFreshness: Double {
        if let s = shownFreshness { return s }
        return brain.lastDecay >= 2 ? brain.freshnessBeforeDecay : brain.freshness
    }
    private var displayFriedPct: Int { Int((100 - displayFreshness).rounded()) }
    private func freshLabel(_ f: Double) -> String {
        switch f { case 75...: return "Crisp"; case 50..<75: return "Toasting"; case 25..<50: return "Frying"; default: return "Burnt" }
    }

    private var score: FriedScore { app.result ?? FriedScore(value: 0, tier: .crispMind) }
    private var brainAge: Int {
        BrainAgeEngine.brainAge(realAge: app.age, score: score, reaction: app.reaction, freshness: brain.freshness)
    }
    private var breakdown: BrainBreakdown {
        BrainBreakdownEngine.make(quiz: app.quiz, reaction: app.reaction, screenTime: app.screenTime,
                                  overall: score.value, age: app.age)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                header
                yolkieNudge
                milestoneBanner
                if showDamage { damageBanner }
                brainHero
                brainAgeCard
                headroomCard
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
        .onAppear(perform: settleOnAppear)
        .sensoryFeedback(.impact(weight: .heavy, intensity: 0.9), trigger: thudTick)
        .sensoryFeedback(.success, trigger: successTick)
        .task {
            if isPreview {
                brain.registerScore(score.value)
                shownFreshness = brain.freshness
                #if DEBUG
                if ProcessInfo.processInfo.environment["FRIED_PREVIEW_DAMAGE"] == "1" {
                    brain.seedReturn()
                    showDamage = true
                    shownFreshness = brain.freshnessBeforeDecay
                    withAnimation(.easeOut(duration: 1.3)) { shownFreshness = brain.freshness }
                }
                #endif
            }
            history.record(score.value)
            await NotificationManager.refreshAI(friedPercent: brain.friedPercent, brainAge: brainAge,
                                                realAge: app.age, topLeak: breakdown.topLeak.label, streak: history.streak)
            plan = PlanEngine.plan(score: score, quiz: app.quiz, reaction: app.reaction)
            await reportStore.ensure(reportContext())
            analysis = await AnalysisEngine.analyze(score: score, quiz: app.quiz, reaction: app.reaction)
            let line = await NudgeEngine.proactiveLine(friedPercent: brain.friedPercent, brainAge: brainAge,
                                                       realAge: app.age, topLeak: breakdown.topLeak.label, streak: history.streak)
            withAnimation(.easeInOut(duration: 0.4)) { proactiveLine = line }
            await maybeShowGoal()
            await maybePrimeNotifications()
        }
        .sheet(isPresented: $showGoalSheet) { goalSheet }
        .sheet(isPresented: $showNotifPrime) { notifPrimeSheet }
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
            streakChip
        }
    }

    // Streak-as-loss: the number you fear losing. Red + dimmed when today isn't secured.
    private var streakSecured: Bool { challenge.completed(of: plan?.steps.count ?? 6) > 0 }
    private var streakAtRisk: Bool { history.streak >= 1 && !streakSecured }
    private var streakChip: some View {
        HStack(spacing: 5) {
            Text("🔥").font(.system(size: 15)).grayscale(streakAtRisk ? 0.85 : 0).opacity(streakAtRisk ? 0.7 : 1)
            Text("\(history.streak)").font(Theme.body(17)).fontWeight(.semibold)
                .foregroundStyle(streakAtRisk ? Theme.danger : Theme.textPrimary)
        }
        .padding(.horizontal, 14).padding(.vertical, 9).friedGlass(cornerRadius: 16)
    }

    // The living brain — FREE (the insecurity hook). Everything reads
    // displayFreshness so the egg, bar and number animate together.
    private var brainHero: some View {
        let f = displayFreshness
        let barColor = f > 60 ? Theme.mint : (f > 35 ? Theme.amber : Theme.ember)
        return GlassCard {
            VStack(spacing: 14) {
                ZStack(alignment: .top) {
                    EggMascot(mood: .forFreshness(f), friedLevel: (100 - f) / 100, size: 132)
                        .padding(.top, 4)
                    if let g = gainPop {       // the dopamine: a +N that floats off the egg
                        Text("+\(g)")
                            .font(Theme.score(32)).foregroundStyle(Theme.mint)
                            .shadow(color: Theme.mint.opacity(0.7), radius: 10)
                            .offset(y: -10)
                            .transition(.asymmetric(insertion: .scale.combined(with: .opacity),
                                                    removal: .move(edge: .top).combined(with: .opacity)))
                    }
                }
                Text("\(displayFriedPct)% fried · \(freshLabel(f))")
                    .font(Theme.title(22)).foregroundStyle(Theme.textPrimary)
                    .contentTransition(.numericText(value: Double(displayFriedPct)))
                GeometryReader { g in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.white.opacity(0.08))
                        Capsule().fill(barColor)
                            .frame(width: max(10, g.size.width * f / 100))
                    }
                }
                .frame(height: 8).padding(.horizontal, 2)
                Text(liveStatusLine)
                    .font(Theme.body(14))
                    .foregroundStyle(f < 40 ? Theme.ember : Theme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(22).frame(maxWidth: .infinity)
        }
    }

    /// Always-on "it's alive and rotting right now" readout.
    private var liveStatusLine: String {
        let h = Int(brain.hoursSinceCool.rounded())
        if brain.freshness < 40 {
            return h >= 1 ? "🔥 Still frying · last cooled \(h)h ago — cool it down below."
                          : "🔥 Frying right now — cool it down below."
        } else if brain.freshness < 70 {
            return "Toasting. It fries a little more every hour you ignore it."
        }
        return "Crisp — for now. Skip a day and it starts frying again."
    }

    /// The loss-aversion centrepiece: watch the bar drain, feel the thud.
    private func settleOnAppear() {
        guard shownFreshness == nil else { return }
        if brain.lastDecay >= 2 && !isPreview {
            showDamage = true
            thudTick += 1
            withAnimation(.easeOut(duration: 1.2).delay(0.4)) { shownFreshness = brain.freshness }
        } else if !isPreview {
            shownFreshness = brain.freshness
        }
    }

    // "While you were gone" — the damage made visible. FREE (drives the paywall).
    private var damageBanner: some View {
        let years = brainAgeBefore.map { max(0, brainAge - $0) } ?? 0
        return GlassCard {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "chart.line.downtrend.xyaxis")
                    .font(.system(size: 22, weight: .semibold)).foregroundStyle(Theme.ember)
                    .padding(.top, 1)
                VStack(alignment: .leading, spacing: 3) {
                    Text("While you were gone").font(Theme.title(17)).foregroundStyle(Theme.textPrimary)
                    Text(damageLine(years: years)).font(Theme.body(14))
                        .foregroundStyle(Theme.textSecondary).fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
                Button { withAnimation { showDamage = false } } label: {
                    Image(systemName: "xmark").font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Theme.textSecondary)
                }
            }
            .padding(18)
        }
        .overlay(RoundedRectangle(cornerRadius: Theme.radius).stroke(Theme.ember.opacity(0.5), lineWidth: 1))
        .transition(.move(edge: .top).combined(with: .opacity))
    }

    private var brainAgeBefore: Int? {
        guard brain.lastDecay >= 2 else { return nil }
        return BrainAgeEngine.brainAge(realAge: app.age, score: score,
                                       reaction: app.reaction, freshness: brain.freshnessBeforeDecay)
    }
    private func damageLine(years: Int) -> String {
        let pct = max(1, Int(brain.lastDecay.rounded()))
        let h = Int(brain.awayHours.rounded())
        let timePart = h >= 24 ? "\(h / 24)d" : "\(max(1, h))h"
        if years >= 1 {
            return "Your brain fried \(pct)% more and aged \(years) year\(years == 1 ? "" : "s") in the last \(timePart). Cool it down ↓"
        }
        return "Your brain fried \(pct)% more in the last \(timePart). Cool it down ↓"
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

    // Proactive Yolkie — a one-line AI take that greets you on the dashboard.
    @ViewBuilder private var yolkieNudge: some View {
        if !proactiveLine.isEmpty {
            Button { withAnimation { router.sel = 2 } } label: {
                HStack(spacing: 12) {
                    AnimatedYolkie(size: 46, fried: brain.friedLevel)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(proactiveLine)
                            .font(Theme.body(14)).foregroundStyle(Theme.textPrimary)
                            .multilineTextAlignment(.leading).fixedSize(horizontal: false, vertical: true)
                        Text("Tap to ask Yolkie →").font(Theme.label(11)).foregroundStyle(Theme.amber)
                    }
                    Spacer(minLength: 0)
                }
                .padding(14).frame(maxWidth: .infinity).friedGlass(cornerRadius: 18)
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(Theme.amber.opacity(0.25), lineWidth: 1))
            }
            .buttonStyle(.plain)
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }

    // #2 "Potential you" — the recoverable headroom, the daily aspiration (FREE).
    // Uses the brain state's fried% so it matches the hero number exactly (clarity).
    private var headroomTarget: Int { app.goal != 0 ? app.goal : 18 }
    private var headroomGap: Int { max(0, brain.friedPercent - headroomTarget) }
    private var headroomCard: some View {
        let reached = headroomGap == 0
        let hasGoal = app.goal != 0
        return GlassCard {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 0) {
                    Text(reached ? "ON TARGET" : "HEADROOM").font(Theme.label(12)).tracking(1.3).foregroundStyle(Theme.textSecondary)
                    Text(reached ? "🎯" : "\(headroomGap)").font(Theme.score(46)).foregroundStyle(Theme.recovery)
                }
                Rectangle().fill(Theme.hairline).frame(width: 1, height: 52)
                VStack(alignment: .leading, spacing: 4) {
                    Text(reached ? "You hit your goal — hold it."
                                 : (hasGoal ? "points to your goal" : "points you can claw back"))
                        .font(Theme.body(15)).foregroundStyle(Theme.textPrimary)
                    Text(hasGoal ? "Target \(app.goal)% · you're at \(brain.friedPercent)%."
                                 : "A fresh brain sits near 18% fried — you're at \(brain.friedPercent)%.")
                        .font(Theme.label(13)).foregroundStyle(Theme.textSecondary)
                }
                Spacer(minLength: 0)
            }
            .padding(20).frame(maxWidth: .infinity)
        }
    }

    // #3 Share at a pride moment — streak milestones only, once each (the viral loop).
    private var milestone: Int? {
        let s = history.streak
        guard [3, 7, 14, 30, 60, 100].contains(s), !dismissedMilestone,
              !UserDefaults.standard.bool(forKey: "fried.shared.\(s)") else { return nil }
        return s
    }
    @ViewBuilder private var milestoneBanner: some View {
        if let m = milestone {
            GlassCard {
                HStack(spacing: 12) {
                    Text("🔥").font(.system(size: 26))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(m)-day streak!").font(Theme.title(17)).foregroundStyle(Theme.textPrimary)
                        Text("You've out-lasted most people. Flex it.")
                            .font(Theme.label(13)).foregroundStyle(Theme.textSecondary)
                    }
                    Spacer(minLength: 0)
                    ShareLink(item: URL(string: "https://fried.app")!,
                              message: Text("🔥 \(m)-day streak on Fried. How fried is your brain?")) {
                        Text("Share").font(Theme.label(13)).fontWeight(.semibold).foregroundStyle(.black)
                            .padding(.horizontal, 14).padding(.vertical, 8)
                            .background(Theme.amber, in: Capsule())
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        UserDefaults.standard.set(true, forKey: "fried.shared.\(m)")
                    })
                    Button { withAnimation { dismissedMilestone = true } } label: {
                        Image(systemName: "xmark").font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Theme.textSecondary)
                    }
                }
                .padding(16)
            }
            .overlay(RoundedRectangle(cornerRadius: Theme.radius).stroke(Theme.amber.opacity(0.4), lineWidth: 1))
            .transition(.move(edge: .top).combined(with: .opacity))
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
                if streakAtRisk {
                    (Text("🔥 Complete 1 to keep your ")
                     + Text("\(history.streak)-day streak").foregroundColor(Theme.danger).bold()
                     + Text(" — it resets at midnight."))
                        .font(Theme.label(12)).foregroundStyle(Theme.textSecondary)
                } else {
                    Text("Each one cools your brain. Skip a day and it fries again.")
                        .font(Theme.label(12)).foregroundStyle(Theme.textSecondary)
                }
            }
            .padding(20).frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func toggleTask(_ i: Int) {
        let wasDone = challenge.isDone(i)
        challenge.toggle(i)
        brain.recover(wasDone ? -7 : 7)
        withAnimation(.spring(response: 0.45, dampingFraction: 0.7)) { shownFreshness = brain.freshness }
        guard !wasDone else { return }      // only celebrate completing, not un-checking
        successTick += 1                    // success haptic
        withAnimation(.spring(response: 0.4, dampingFraction: 0.55)) { gainPop = 7 }
        Task {
            try? await Task.sleep(for: .seconds(0.9))
            withAnimation(.easeIn(duration: 0.3)) { gainPop = nil }
        }
    }

    // Benefit-first priming BEFORE the one-shot system prompt — shown once, only
    // if they've never been asked. Research: warm-up screens lift opt-in materially.
    private func maybePrimeNotifications() async {
        // Sequenced AFTER the goal is set, so the two first-run sheets never stack.
        guard !isPreview, app.goal != 0, !UserDefaults.standard.bool(forKey: "fried.primedNotif") else { return }
        guard await NotificationManager.isUndetermined() else { return }
        try? await Task.sleep(for: .seconds(0.8))
        withAnimation { showNotifPrime = true }
    }

    // First session: pick an explicit target (goal-gradient — a finish line accelerates effort).
    private func maybeShowGoal() async {
        let forced = ProcessInfo.processInfo.environment["FRIED_PREVIEW_GOAL"] == "1"
        guard forced || (!isPreview && app.goal == 0) else { return }
        goalSel = max(10, min(60, brain.friedPercent - 25))   // a sensible, reachable default
        try? await Task.sleep(for: .seconds(0.5))
        showGoalSheet = true
    }

    private var goalSheet: some View {
        VStack(spacing: 16) {
            Text("🎯").font(.system(size: 44))
            Text("Set your target").font(Theme.title(24)).foregroundStyle(Theme.textPrimary)
            Text("Where do you want your brain? We'll track you toward it every day.")
                .font(Theme.body(15)).foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center).padding(.horizontal, 18)
            Text("\(goalSel)").font(Theme.hero(64)).foregroundStyle(Theme.recovery)
            Text("fried or lower").font(Theme.label(13)).foregroundStyle(Theme.textSecondary)
            Slider(value: Binding(get: { Double(goalSel) }, set: { goalSel = Int(($0 / 5).rounded()) * 5 }),
                   in: 5...60, step: 5)
                .tint(Theme.recovery).padding(.horizontal, 30)
            PrimaryButton(title: "Lock in my goal") {
                app.setGoal(goalSel)
                showGoalSheet = false
            }
        }
        .padding(28)
        .presentationDetents([.height(440)])
        .presentationBackground(.ultraThinMaterial)
    }

    private var notifPrimeSheet: some View {
        VStack(spacing: 18) {
            Text("🔔").font(.system(size: 46))
            Text("Catch your brain frying")
                .font(Theme.title(23)).foregroundStyle(Theme.textPrimary).multilineTextAlignment(.center)
            Text("One quiet daily nudge when your brain needs cooling — and before your streak resets. No spam, ever.")
                .font(Theme.body(15)).foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center).padding(.horizontal, 18)
            PrimaryButton(title: "Turn on reminders") {
                UserDefaults.standard.set(true, forKey: "fried.primedNotif")
                Task { _ = await NotificationManager.requestAndSchedule(); showNotifPrime = false }
            }
            Button("Maybe later") {
                UserDefaults.standard.set(true, forKey: "fried.primedNotif")
                showNotifPrime = false
            }
            .font(Theme.body(15)).foregroundStyle(Theme.textSecondary).padding(.top, 2)
        }
        .padding(28)
        .presentationDetents([.height(380)])
        .presentationBackground(.ultraThinMaterial)
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
                Text("Your progress")
                    .font(Theme.title(28)).foregroundStyle(Theme.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                progressHero
                chartCard
                recordStrip
                Text("Your streak holds your progress — miss a day and the trend resets.")
                    .font(Theme.label(13)).foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center).padding(.horizontal, 20).padding(.top, 2)
            }
            .padding(.horizontal, Theme.pad).padding(.top, 64).padding(.bottom, 40)
        }
        .scrollIndicators(.hidden)
        .task { if ProcessInfo.processInfo.environment["FRIED_PREVIEW_SCREEN"] == "home" { history.seedSampleIfEmpty() } }
    }

    // Loss aversion + endowment + goal-gradient: make banked progress felt so they protect it.
    private var progressHero: some View {
        let p = progress
        return GlassCard {
            VStack(spacing: 8) {
                Text(p.label).font(Theme.label(12)).tracking(1.5).foregroundStyle(Theme.textSecondary)
                Text(p.big).font(Theme.hero(60)).foregroundStyle(p.good ? Theme.recovery : Theme.danger)
                Text(p.sub).font(Theme.body(15)).foregroundStyle(Theme.textPrimary)
                    .multilineTextAlignment(.center).fixedSize(horizontal: false, vertical: true)
            }
            .padding(24).frame(maxWidth: .infinity)
        }
    }

    private var chartCard: some View {
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
            }
            .padding(20).frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var recordStrip: some View {
        HStack(spacing: 12) {
            miniStat("🏆 RECORD", history.days.map(\.value).min().map { "\($0)" } ?? "—", Theme.recovery)
            miniStat("🔥 STREAK", "\(history.streak)", Theme.amber)
        }
    }
    private func miniStat(_ tag: String, _ value: String, _ color: Color) -> some View {
        GlassCard {
            VStack(spacing: 4) {
                Text(tag).font(Theme.label(11)).tracking(1).foregroundStyle(Theme.textSecondary)
                Text(value).font(Theme.hero(34)).foregroundStyle(color)
            }
            .padding(.vertical, 16).frame(maxWidth: .infinity)
        }
    }

    /// The progress story — lower fried = better, so improvement is "clawed back".
    private var progress: (label: String, big: String, sub: String, good: Bool) {
        let vals = history.days.map(\.value)
        guard let current = vals.last else {
            return ("YOUR PROGRESS", "—", "Take the test daily to build your trend.", true)
        }
        let best = vals.min() ?? current
        let start = vals.first ?? current
        let clawed = start - current
        if vals.count >= 2 && current <= best {
            return ("SHARPEST YOU'VE BEEN", "\(current)", "Your lowest fried score yet. Don't lose it.", true)
        } else if clawed > 0 {
            return ("CLAWED BACK", "\(clawed)", "points since you started. \(best) is your record — beat it.", true)
        } else if clawed < 0 {
            return ("TRENDING UP", "+\(-clawed)", "more fried than when you started. Reverse it before it sticks.", false)
        }
        return ("HOLDING STEADY", "\(current)", "Keep the streak alive to start clawing it back.", true)
    }
}

// MARK: - You / Profile

struct ProfileView: View {
    @EnvironmentObject var app: AppState
    @EnvironmentObject var store: Store
    @EnvironmentObject var history: HistoryStore
    @EnvironmentObject var archetypeStore: ArchetypeStore
    @AppStorage("fried.notif.on") private var notifOn = false
    @State private var shareCardImage: Image?

    private var score: FriedScore { app.result ?? FriedScore(value: 0, tier: .crispMind) }
    private var breakdown: BrainBreakdown {
        BrainBreakdownEngine.make(quiz: app.quiz, reaction: app.reaction, screenTime: app.screenTime,
                                  overall: score.value, age: app.age)
    }
    private func regenShareCard() {
        shareCardImage = ShareCard.image(score: score, breakdown: breakdown,
                                         archetype: archetypeStore.archetype, roast: "")
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("You")
                    .font(Theme.title(28)).foregroundStyle(Theme.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                archetypeCard
                statsGrid
                accessCard
                notifCard
                settingsCard
                Text("Fried is for entertainment only — a playful vibe check, not a measurement of your health, focus, or intelligence.")
                    .font(.system(size: 11)).foregroundStyle(Theme.textSecondary.opacity(0.6))
                    .multilineTextAlignment(.center).padding(.horizontal, 16).padding(.top, 6)
            }
            .padding(.horizontal, Theme.pad).padding(.top, 64).padding(.bottom, 40)
        }
        .scrollIndicators(.hidden)
        .task {
            await archetypeStore.ensure(score: score, breakdown: breakdown)
            regenShareCard()
        }
        .onChange(of: archetypeStore.archetype) { _, _ in regenShareCard() }
    }

    // The AI wow: an on-device-generated identity + variable reward (re-roll).
    private var archetypeCard: some View {
        GlassCard {
            VStack(spacing: 12) {
                Text("YOUR BRAIN ARCHETYPE").font(Theme.label(12)).tracking(1.5).foregroundStyle(Theme.textSecondary)
                Image(systemName: "sparkles").font(.system(size: 18)).foregroundStyle(Theme.amber)
                if let a = archetypeStore.archetype, !archetypeStore.loading {
                    Text(a.title).font(Theme.title(26)).foregroundStyle(Theme.gradient(for: score.tier))
                        .multilineTextAlignment(.center)
                    Text(a.blurb).font(Theme.body(15)).foregroundStyle(Theme.textPrimary)
                        .multilineTextAlignment(.center).fixedSize(horizontal: false, vertical: true)
                } else {
                    ProgressView().tint(Theme.amber).padding(.vertical, 14)
                    Text("Reading your brain…").font(Theme.label(13)).foregroundStyle(Theme.textSecondary)
                }
                HStack(spacing: 12) {
                    Button { Task { await archetypeStore.reroll(score: score, breakdown: breakdown) } } label: {
                        Label(archetypeStore.loading ? "Conjuring…" : "Re-roll", systemImage: "dice.fill")
                            .font(Theme.label(14)).fontWeight(.semibold).foregroundStyle(Theme.amber)
                            .padding(.horizontal, 16).padding(.vertical, 9)
                            .liquidGlass(in: Capsule(), interactive: true)
                    }
                    .buttonStyle(.plain).disabled(archetypeStore.loading)
                    if let img = shareCardImage {
                        ShareLink(item: img,
                                  message: Text("My brain type: \(archetypeStore.archetype?.title ?? "") 🍳 What's yours? fried.app"),
                                  preview: SharePreview("My Brain Type", image: img)) {
                            Label("Share", systemImage: "square.and.arrow.up")
                                .font(Theme.label(14)).foregroundStyle(Theme.textPrimary)
                                .padding(.horizontal, 16).padding(.vertical, 9)
                                .liquidGlass(in: Capsule(), interactive: true)
                        }
                    }
                }
                .padding(.top, 4)
            }
            .padding(22).frame(maxWidth: .infinity)
            .animation(.easeInOut(duration: 0.3), value: archetypeStore.archetype)
        }
    }

    // Lifetime stats — accumulated progress you protect (endowment effect).
    private var statsGrid: some View {
        let vals = history.days.map(\.value)
        let clawed = max(0, (vals.first ?? 0) - (vals.min() ?? 0))
        return LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            statBox("\(vals.count)", "tests taken", Theme.textPrimary)
            statBox(vals.min().map { "\($0)" } ?? "—", "best score", Theme.recovery)
            statBox("\(history.longestStreak)", "best streak", Theme.amber)
            statBox("\(clawed)", "points clawed back", Theme.recovery)
        }
    }
    private func statBox(_ value: String, _ label: String, _ color: Color) -> some View {
        GlassCard {
            VStack(spacing: 4) {
                Text(value).font(Theme.hero(38)).foregroundStyle(color)
                Text(label).font(Theme.label(12)).foregroundStyle(Theme.textSecondary)
            }
            .padding(.vertical, 18).frame(maxWidth: .infinity)
        }
    }

    @ViewBuilder private var accessCard: some View {
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
    }

    private var notifCard: some View {
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
    }

    private var settingsCard: some View {
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
