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
    @Published var screenTime: ScreenTimeResult? = nil
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

    /// The user's target fried score (0 = not set yet) — their explicit finish line.
    @Published var goal: Int = UserDefaults.standard.integer(forKey: "fried.goal")
    func setGoal(_ g: Int) {
        goal = g
        UserDefaults.standard.set(g, forKey: "fried.goal")
    }

    init() {
        if let p = ProcessInfo.processInfo.environment["FRIED_PREVIEW_SCREEN"] {
            applyPreview(p)
            return
        }
        restoreSession()   // returning user → straight to the dashboard, not onboarding
    }

    /// A returning user already onboarded — restore their result and land on home.
    private func restoreSession() {
        let d = UserDefaults.standard
        guard d.bool(forKey: "fried.onboarded") else { return }   // first run → splash → onboarding
        let value = d.integer(forKey: "fried.result.value")
        result = FriedScore(value: value, tier: FriedTier(score: value))
        if let answers = d.array(forKey: "fried.quiz.answers") as? [Int] {
            quiz = QuizResult(answerIndices: answers, maxIndex: max(1, d.integer(forKey: "fried.quiz.max")))
        }
        reaction = ReactionResult(meanMillis: d.double(forKey: "fried.reaction.mean"),
                                  lapseVariance: d.double(forKey: "fried.reaction.lapse"))
        let mins = d.integer(forKey: "fried.screen.minutes")
        if mins > 0 { screenTime = ScreenTimeResult(totalMinutes: mins, apps: []) }
        screen = .home
    }

    private func persistSession() {
        let d = UserDefaults.standard
        d.set(true, forKey: "fried.onboarded")
        d.set(result?.value ?? 0, forKey: "fried.result.value")
        if let q = quiz {
            d.set(q.answerIndices, forKey: "fried.quiz.answers")
            d.set(q.maxIndex, forKey: "fried.quiz.max")
        }
        if let r = reaction {
            d.set(r.meanMillis, forKey: "fried.reaction.mean")
            d.set(r.lapseVariance, forKey: "fried.reaction.lapse")
        }
        d.set(screenTime?.totalMinutes ?? 0, forKey: "fried.screen.minutes")
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
        self.result = ScoringEngine.score(quiz: quiz, reaction: reaction, screenTime: screenTime)
        persistSession()   // so the next launch lands on home, not onboarding
        withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) { screen = .calculating }
    }
}
