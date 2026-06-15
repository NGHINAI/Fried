import SwiftUI
import Foundation

/// The live, zero-permission "wow" data: a 5-round tap-the-green reaction test.
/// Produces a ReactionResult (mean + erraticness) that feeds the score.
struct ReactionGauntletView: View {
    @EnvironmentObject var app: AppState
    let quiz: QuizResult

    @State private var phase: Phase = .intro
    @State private var round = 0
    @State private var times: [Double] = []
    @State private var greenSince: Date?
    @State private var token = 0
    @State private var tapTrigger = false
    private let total = 5

    enum Phase { case intro, armed, go, tooSoon, result }

    var body: some View {
        VStack(spacing: 16) {
            Text(headline)
                .font(Theme.title(25))
                .foregroundStyle(Theme.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
                .padding(.top, 64)
            Text("Round \(min(round + 1, total)) / \(total)")
                .font(Theme.label())
                .foregroundStyle(Theme.textSecondary)
                .opacity(phase == .intro || phase == .result ? 0 : 1)
            Spacer()
            ZStack {
                RoundedRectangle(cornerRadius: 44, style: .continuous)
                    .fill(padColor)
                    .shadow(color: padColor.opacity(0.45), radius: 30)
                Text(padText)
                    .font(Theme.title(26))
                    .foregroundStyle(.black.opacity(0.82))
                    .multilineTextAlignment(.center)
                    .padding()
            }
            .frame(height: 340)
            .padding(.horizontal, Theme.pad)
            .contentShape(RoundedRectangle(cornerRadius: 44, style: .continuous))
            .onTapGesture { handleTap() }
            Text(subtext)
                .font(Theme.body(15))
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 34)
                .frame(height: 44)
            Spacer()
        }
        .sensoryFeedback(.impact(weight: .medium), trigger: tapTrigger)
    }

    // MARK: copy
    private var headline: String {
        switch phase {
        case .tooSoon: return "Too soon! 😅"
        case .result:  return "Reflexes logged."
        default:       return "Tap the instant it turns green"
        }
    }
    private var subtext: String {
        switch phase {
        case .intro:   return "We're measuring your reflexes. Don't think — just tap."
        case .armed:   return "Wait for green…"
        case .go:      return "NOW!"
        case .tooSoon: return "You jumped the gun. Tap to retry the round."
        case .result:  return "Plating your results…"
        }
    }
    private var padColor: Color {
        switch phase {
        case .intro:   return Theme.mint.opacity(0.85)
        case .armed:   return Color(red: 0.80, green: 0.16, blue: 0.14)
        case .go:      return Theme.mint
        case .tooSoon: return Theme.heatMid
        case .result:  return Theme.heatTop
        }
    }
    private var padText: String {
        switch phase {
        case .intro:   return "Tap to start"
        case .armed:   return "Wait…"
        case .go:      return "TAP!"
        case .tooSoon: return "Tap to retry"
        case .result:  return "Nice 🔥"
        }
    }

    // MARK: logic
    private func handleTap() {
        tapTrigger.toggle()
        switch phase {
        case .intro, .tooSoon:
            arm()
        case .armed:
            token += 1            // invalidate the pending green
            phase = .tooSoon
        case .go:
            if let g = greenSince {
                times.append(Date().timeIntervalSince(g) * 1000)
            }
            round += 1
            if round >= total { finish() } else { arm() }
        case .result:
            break
        }
    }

    private func arm() {
        phase = .armed
        token += 1
        let myToken = token
        let delay = Double.random(in: 1.1...2.6)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            guard myToken == token, phase == .armed else { return }
            greenSince = Date()
            phase = .go
            tapTrigger.toggle()
        }
    }

    private func finish() {
        phase = .result
        let mean = times.isEmpty ? 380 : times.reduce(0, +) / Double(times.count)
        let variance = times.isEmpty ? 0 : times.reduce(0) { $0 + pow($1 - mean, 2) } / Double(times.count)
        let std = sqrt(variance)
        let lapse = min(1.5, std / 250)
        let reaction = ReactionResult(meanMillis: mean, lapseVariance: lapse)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            app.finishOnboarding(quiz: quiz, reaction: reaction)
        }
    }
}
