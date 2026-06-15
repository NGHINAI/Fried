import SwiftUI

struct OnboardingFlow: View {
    @EnvironmentObject var app: AppState
    @State private var index = 0
    @State private var answers: [Int] = []
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
            } else {
                quiz
            }
        }
        .onAppear {
            if app.jumpToGauntlet {
                if let q = app.quiz { answers = q.answerIndices }
                showGauntlet = true
                app.jumpToGauntlet = false
            }
        }
    }

    /// Emotional gut-punch before the reflex test — the insecurity hook.
    private var interstitial: some View {
        VStack(spacing: 24) {
            Spacer()
            Text("📱").font(.system(size: 60))
            Text("You check your phone\n~144 times a day.")
                .font(Theme.title(30)).foregroundStyle(Theme.textPrimary)
                .multilineTextAlignment(.center)
            GlassCard {
                Text("Most people can't go 10 minutes without a scroll. Your habits are in — now let's see what they did to your focus.")
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
            withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) { showInterstitial = true }
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
