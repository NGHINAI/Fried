import SwiftUI
import Charts

/// The retention home: today's score, de-fry streak, 7-day trend, the unlocked
/// breakdown, today's roast, and the daily re-test loop.
struct HomeView: View {
    @EnvironmentObject var app: AppState
    @EnvironmentObject var history: HistoryStore
    @State private var roast = ""

    private var score: FriedScore { app.result ?? FriedScore(value: 0, tier: .crispMind) }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                header
                scoreCard
                trendCard
                breakdownCard
                roastCard
                PrimaryButton(title: "Re-test my reflexes") {
                    app.jumpToGauntlet = true
                    withAnimation { app.screen = .onboarding }
                }
                .padding(.top, 4)
            }
            .padding(.horizontal, Theme.pad)
            .padding(.top, 60)
            .padding(.bottom, 44)
        }
        .scrollIndicators(.hidden)
        .task {
            if ProcessInfo.processInfo.environment["FRIED_PREVIEW_SCREEN"] == "home" {
                history.seedSampleIfEmpty()
            }
            history.record(score.value)
            roast = await RoastEngine.roast(for: score)
        }
    }

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Your brain today")
                    .font(Theme.title(26)).foregroundStyle(Theme.textPrimary)
                Text(Date().formatted(.dateTime.weekday(.wide).month().day()))
                    .font(Theme.label(13)).foregroundStyle(Theme.textSecondary)
            }
            Spacer()
            HStack(spacing: 5) {
                Text("🔥").font(.system(size: 15))
                Text("\(history.streak)").font(Theme.body(17)).fontWeight(.bold)
                    .foregroundStyle(Theme.textPrimary)
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
                        .stroke(Theme.gradient(for: score.tier),
                                style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    Text("\(score.value)").font(Theme.score(34))
                        .foregroundStyle(Theme.gradient(for: score.tier))
                }
                .frame(width: 92, height: 92)
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(score.tier.emoji) \(score.tier.title)")
                        .font(Theme.title(22)).foregroundStyle(Theme.textPrimary)
                    Text("Today's fried score").font(Theme.label(13)).foregroundStyle(Theme.textSecondary)
                }
                Spacer(minLength: 0)
            }
            .padding(20)
            .frame(maxWidth: .infinity)
        }
    }

    private var trendCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("LAST 7 DAYS").font(Theme.label(12)).tracking(1.5)
                    .foregroundStyle(Theme.textSecondary)
                Chart(history.last7) { d in
                    BarMark(x: .value("Day", d.date, unit: .day),
                            y: .value("Score", d.value), width: .ratio(0.55))
                        .foregroundStyle(Theme.heatGradient)
                        .cornerRadius(5)
                }
                .chartYScale(domain: 0...100)
                .chartXAxis { AxisMarks(values: .stride(by: .day)) {
                    AxisValueLabel(format: .dateTime.weekday(.narrow))
                        .foregroundStyle(Theme.textSecondary)
                } }
                .chartYAxis(.hidden)
                .frame(height: 128)
                if let delta = weekDelta {
                    Text(delta.text).font(Theme.body(14)).fontWeight(.semibold)
                        .foregroundStyle(delta.good ? Theme.mint : Theme.amber)
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var breakdownCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("THE BREAKDOWN").font(Theme.label(12)).tracking(1.5)
                    .foregroundStyle(Theme.textSecondary)
                ForEach(subScores, id: \.0) { item in
                    bar(item.0, item.1)
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var roastCard: some View {
        GlassCard {
            HStack(alignment: .top, spacing: 12) {
                Text("🔥").font(.system(size: 22))
                Text(roast.isEmpty ? " " : roast)
                    .font(Theme.body(16)).foregroundStyle(Theme.textPrimary)
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
                    Capsule().fill(Theme.heatGradientH)
                        .frame(width: max(8, g.size.width * Double(val) / 100))
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
        return [
            ("Scroll habits", min(100, base + 6)),
            ("Reflex lag", max(0, base - 8)),
            ("Focus drift", min(100, base + 2))
        ]
    }

    private var weekDelta: (text: String, good: Bool)? {
        let d = history.last7
        guard d.count >= 2, let first = d.first, let last = d.last else { return nil }
        let diff = last.value - first.value
        if diff == 0 { return ("No change this week", true) }
        return diff < 0
            ? ("↓ \(abs(diff)) less fried this week", true)
            : ("↑ \(diff) more fried this week", false)
    }
}
