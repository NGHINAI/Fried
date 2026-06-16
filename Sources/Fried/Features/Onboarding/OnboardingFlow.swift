import SwiftUI

struct OnboardingFlow: View {
    @EnvironmentObject var app: AppState
    @State private var index = 0
    @State private var answers: [Int] = []
    @State private var askedAge = false
    @State private var ageSel = 24
    @State private var showScreenTime = false
    @State private var showInterstitial = false
    @State private var showGauntlet = false

    var body: some View {
        Group {
            if showGauntlet {
                ReactionGauntletView(
                    quiz: QuizResult(answerIndices: answers.isEmpty ? [1, 1, 1, 1, 1, 1] : answers,
                                     maxIndex: QuizContent.maxIndex))
            } else if showInterstitial {
                interstitial
            } else if showScreenTime {
                screenTimeStep
            } else if askedAge {
                quiz
            } else {
                ageStep
            }
        }
        .onAppear {
            ageSel = app.age
            if app.jumpToGauntlet {
                if let q = app.quiz { answers = q.answerIndices }
                askedAge = true
                showGauntlet = true
                app.jumpToGauntlet = false
            }
        }
    }

    private var ageStep: some View {
        VStack(spacing: 22) {
            ProgressBar(progress: 1.0 / 8.0)
                .padding(.top, 60).padding(.horizontal, Theme.pad)
            Spacer()
            EggMascot(mood: .curious, size: 96)
            Text("First — how old are you?")
                .font(Theme.title(28)).foregroundStyle(Theme.textPrimary)
            Text("So we can compare your brain age to your real age.")
                .font(Theme.body(15)).foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center).padding(.horizontal, 36)
            Picker("Age", selection: $ageSel) {
                ForEach(13...80, id: \.self) { Text("\($0)").tag($0) }
            }
            .pickerStyle(.wheel)
            .frame(height: 170)
            Spacer()
            PrimaryButton(title: "Continue") {
                app.setAge(ageSel)
                withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) { askedAge = true }
            }
            .padding(.horizontal, Theme.pad)
            Spacer().frame(height: 16)
        }
    }

    /// Personalized gut-punch before the reflex test — reflects THEIR answers.
    private var interstitial: some View {
        VStack(spacing: 24) {
            Spacer()
            EggMascot(mood: .worried, size: 104)
            Text(interstitialHeadline)
                .font(Theme.title(30)).foregroundStyle(Theme.textPrimary)
                .multilineTextAlignment(.center).padding(.horizontal, 20)
            GlassCard {
                Text(interstitialBody)
                    .font(Theme.body(17)).foregroundStyle(Theme.textPrimary)
                    .multilineTextAlignment(.center).padding(22).frame(maxWidth: .infinity)
            }
            .padding(.horizontal, Theme.pad)
            Spacer()
            PrimaryButton(title: "I'm ready — test me") {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) { showGauntlet = true }
            }
            .padding(.horizontal, Theme.pad)
            Spacer().frame(height: 16)
        }
        .transition(.blurReplace)
    }

    private var interstitialHeadline: String {
        let total = answers.reduce(0, +)
        let maxTotal = QuizContent.maxIndex * max(answers.count, 1)
        let ratio = maxTotal > 0 ? Double(total) / Double(maxTotal) : 0.5
        switch ratio {
        case 0.66...:       return "Oof. You might be cooked."
        case 0.33..<0.66:   return "You're more fried than you think."
        default:            return "Not bad… but the feed still wants you."
        }
    }

    private var interstitialBody: String {
        guard let worst = answers.enumerated().max(by: { $0.element < $1.element }),
              worst.offset < QuizContent.questions.count else {
            return "Your habits are in — now let's see what they did to your focus."
        }
        let q = QuizContent.questions[worst.offset]
        let ans = q.answers[min(worst.element, q.answers.count - 1)]
        return "You said “\(ans).” Honest. Now let's see what your habits did to your reflexes."
    }

    private var quiz: some View {
        let q = QuizContent.questions[index]
        let count = QuizContent.questions.count
        return VStack(spacing: 0) {
            ProgressBar(progress: Double(index + 1) / Double(count))
                .padding(.top, 60)
                .padding(.horizontal, Theme.pad)
            Text("Question \(index + 1) of \(count)")
                .font(Theme.label(13))
                .foregroundStyle(Theme.textSecondary)
                .padding(.top, 14)

            Spacer().frame(height: 46)

            VStack(spacing: 30) {
                Text(q.prompt)
                    .font(Theme.title(30))
                    .foregroundStyle(Theme.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 22)
                VStack(spacing: 12) {
                    ForEach(Array(q.answers.enumerated()), id: \.offset) { i, ans in
                        AnswerButton(text: ans) { select(i) }
                    }
                }
                .padding(.horizontal, Theme.pad)
            }
            .id(index)
            .transition(.blurReplace)

            Spacer()
        }
    }

    private func select(_ i: Int) {
        answers.append(i)
        if index + 1 < QuizContent.questions.count {
            withAnimation(.smooth(duration: 0.35)) { index += 1 }
        } else {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) { showScreenTime = true }
        }
    }

    /// One more input → more investment (IKEA effect) AND a real signal that
    /// feeds the score (the inputs-must-feed-the-result ethic).
    private var screenTimeStep: some View {
        let options: [(String, Int)] = [
            ("Under 2 hours", 90), ("2–4 hours", 180), ("4–6 hours", 300),
            ("6–8 hours", 420), ("Over 8 hours", 540)
        ]
        return VStack(spacing: 0) {
            ProgressBar(progress: 7.5 / 8.0)
                .padding(.top, 60).padding(.horizontal, Theme.pad)
            Spacer().frame(height: 46)
            VStack(spacing: 28) {
                Text("Your daily screen time?")
                    .font(Theme.title(30)).foregroundStyle(Theme.textPrimary)
                    .multilineTextAlignment(.center).padding(.horizontal, 22)
                Text("Be honest — Settings → Screen Time has the receipts.")
                    .font(Theme.body(15)).foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center).padding(.horizontal, 30)
                VStack(spacing: 12) {
                    ForEach(Array(options.enumerated()), id: \.offset) { _, opt in
                        AnswerButton(text: opt.0) {
                            app.screenTime = ScreenTimeResult(totalMinutes: opt.1, apps: [])
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) { showInterstitial = true }
                        }
                    }
                }
                .padding(.horizontal, Theme.pad)
            }
            .transition(.blurReplace)
            Spacer()
        }
    }
}

struct AnswerButton: View {
    let text: String
    let action: () -> Void
    @State private var trigger = false

    var body: some View {
        Button {
            trigger.toggle()
            action()
        } label: {
            HStack(spacing: 12) {
                Text(text)
                    .font(Theme.body(17))
                    .foregroundStyle(Theme.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Theme.textSecondary.opacity(0.6))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .frame(maxWidth: .infinity)
            .friedGlass(cornerRadius: 18)
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.impact(weight: .light), trigger: trigger)
    }
}

struct ProgressBar: View {
    let progress: Double   // 0...1

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.white.opacity(0.10))
                Capsule().fill(Theme.heatGradientH)
                    .frame(width: max(10, geo.size.width * min(1, progress)))
            }
        }
        .frame(height: 6)
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: progress)
    }
}
