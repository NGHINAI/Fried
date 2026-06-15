import SwiftUI

struct OnboardingFlow: View {
    @EnvironmentObject var app: AppState
    @State private var index = 0
    @State private var answers: [Int] = []
    @State private var showGauntlet = false

    var body: some View {
        Group {
            if showGauntlet {
                ReactionGauntletView(
                    quiz: QuizResult(answerIndices: answers.isEmpty ? [1, 1, 1, 1, 1, 1] : answers,
                                     maxIndex: QuizContent.maxIndex))
            } else {
                quiz
            }
        }
        .onAppear { if app.jumpToGauntlet { showGauntlet = true } }
    }

    private var quiz: some View {
        let q = QuizContent.questions[index]
        return VStack(spacing: 22) {
            ProgressDots(count: QuizContent.questions.count, index: index)
                .padding(.top, 64)
            Spacer()
            Text(q.prompt)
                .font(Theme.title(29))
                .foregroundStyle(Theme.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 26)
            VStack(spacing: 12) {
                ForEach(Array(q.answers.enumerated()), id: \.offset) { i, ans in
                    AnswerButton(text: ans) { select(i) }
                }
            }
            .padding(.horizontal, Theme.pad)
            Spacer()
        }
        .id(index)
        .transition(.asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)))
    }

    private func select(_ i: Int) {
        answers.append(i)
        if index + 1 < QuizContent.questions.count {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) { index += 1 }
        } else {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) { showGauntlet = true }
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
            Text(text)
                .font(Theme.body(17))
                .foregroundStyle(Theme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.vertical, 18)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 18, style: .continuous).fill(.ultraThinMaterial)
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color(red: 1, green: 0.96, blue: 0.92).opacity(0.04))
                    })
                .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(Theme.hairline, lineWidth: 1))
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.impact(weight: .light), trigger: trigger)
    }
}

struct ProgressDots: View {
    let count: Int
    let index: Int

    var body: some View {
        HStack(spacing: 7) {
            ForEach(0..<count, id: \.self) { i in
                Capsule()
                    .fill(i <= index ? AnyShapeStyle(Theme.heatGradientH)
                                     : AnyShapeStyle(Color.white.opacity(0.12)))
                    .frame(width: i == index ? 22 : 7, height: 7)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: index)
    }
}
