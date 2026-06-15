import SwiftUI

enum Screen: Equatable {
    case splash, onboarding, calculating, reveal, home, paywall
}

@MainActor
final class AppState: ObservableObject {
    @Published var screen: Screen = .splash
    @Published var result: FriedScore? = nil
    @Published var reaction: ReactionResult? = nil

    init() {
        // Dev convenience: jump straight to a screen for visual review via
        //   SIMCTL_CHILD_FRIED_PREVIEW_SCREEN=reveal xcrun simctl launch …
        if let p = ProcessInfo.processInfo.environment["FRIED_PREVIEW_SCREEN"] {
            applyPreview(p)
        }
    }

    func applyPreview(_ name: String) {
        switch name {
        case "splash":      screen = .splash
        case "onboarding", "quiz": screen = .onboarding
        case "calculating": screen = .calculating
        case "reveal":      result = FriedScore(value: 87, tier: .extraCrispy); screen = .reveal
        case "reveal_low":  result = FriedScore(value: 18, tier: .crispMind);  screen = .reveal
        case "reveal_mid":  result = FriedScore(value: 64, tier: .wellDone);   screen = .reveal
        case "home":        result = FriedScore(value: 73, tier: .wellDone);   screen = .home
        case "paywall":     result = FriedScore(value: 87, tier: .extraCrispy); screen = .paywall
        default: break
        }
    }

    func finishOnboarding(quiz: QuizResult, reaction: ReactionResult) {
        self.reaction = reaction
        self.result = ScoringEngine.score(quiz: quiz, reaction: reaction, screenTime: nil)
        withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) { screen = .calculating }
    }
}
