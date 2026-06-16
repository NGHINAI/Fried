import SwiftUI

enum Screen: Equatable {
    case splash, onboarding, calculating, reveal, home, paywall
}

@MainActor
final class AppState: ObservableObject {
    @Published var screen: Screen = .splash
    @Published var result: FriedScore? = nil
    @Published var reaction: ReactionResult? = nil
    @Published var quiz: QuizResult? = nil
    @Published var jumpToGauntlet = false
    @Published var paywallReturn: Screen = .reveal
    @Published var age: Int = {
        let saved = UserDefaults.standard.integer(forKey: "fried.age")
        return saved == 0 ? 24 : saved
    }()

    func setAge(_ a: Int) {
        age = a
        UserDefaults.standard.set(a, forKey: "fried.age")
    }

    init() {
        if let p = ProcessInfo.processInfo.environment["FRIED_PREVIEW_SCREEN"] {
            applyPreview(p)
        }
    }

    func applyPreview(_ name: String) {
        switch name {
        case "splash":      screen = .splash
        case "onboarding", "quiz": screen = .onboarding
        case "gauntlet":    screen = .onboarding; jumpToGauntlet = true
        case "calculating": screen = .calculating
        case "reveal":      result = FriedScore(value: 87, tier: .extraCrispy); screen = .reveal
        case "reveal_low":  result = FriedScore(value: 18, tier: .crispMind);  screen = .reveal
        case "reveal_mid":  result = FriedScore(value: 64, tier: .wellDone);   screen = .reveal
        case "home":
            result = FriedScore(value: 73, tier: .wellDone)
            quiz = QuizResult(answerIndices: [2, 2, 3, 2, 2, 3], maxIndex: 3)
            reaction = ReactionResult(meanMillis: 360, lapseVariance: 0.42)
            screen = .home
        case "paywall":     result = FriedScore(value: 87, tier: .extraCrispy); screen = .paywall
        default: break
        }
    }

    func finishOnboarding(quiz: QuizResult, reaction: ReactionResult) {
        self.quiz = quiz
        self.reaction = reaction
        self.result = ScoringEngine.score(quiz: quiz, reaction: reaction, screenTime: nil)
        withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) { screen = .calculating }
    }
}
