import SwiftUI
import Foundation

/// The live, zero-permission "wow" data. Rebuilt for clarity per UX research:
/// an explainer → 1 clearly-labeled PRACTICE round → 3 scored rounds, with
/// explicit Get-ready / Wait / TAP states (words + color, never color alone)
/// and free no-penalty retries on early taps.
struct ReactionGauntletView: View {
    @EnvironmentObject var app: AppState
    let quiz: QuizResult

    enum Pad { case ready, wait, go, early, practiceDone, roundDone }

    @State private var started = false   // false = explainer screen
    @State private var isPractice = true
    @State private var pad: Pad = .ready
    @State private var realDone = 0
    @State private var times: [Double] = []
    @State private var lastMs: Double = 0
    @State private var greenAt: Date?
    @State private var token = 0
    @State private var tap = false
    private let realTotal = 3

    var body: some View {
        VStack(spacing: 0) {
            if started { game } else { explainer }
        }
        .sensoryFeedback(.impact(weight: .medium), trigger: tap)
    }

    // MARK: Explainer
    private var explainer: some View {
        VStack(spacing: 22) {
            Spacer()
            Text("⚡️").font(.system(size: 58))
            Text("Quick reflex check")
                .font(Theme.title(31)).foregroundStyle(Theme.textPrimary)
            VStack(spacing: 16) {
                rule("1", "Wait for the pad to flash ", "green", ".")
                rule("2", "Then tap it as fast as you can.", "", "")
                rule("3", "First round is just ", "practice", " — it won't count.")
            }
            .padding(.horizontal, 6)
            Spacer()
            PrimaryButton(title: "Try it") { startPractice() }
                .padding(.horizontal, Theme.pad)
            Spacer().frame(height: 16)
        }
        .padding(.horizontal, Theme.pad)
        .padding(.vertical, 36)
    }

    private func rule(_ n: String, _ a: String, _ hi: String, _ b: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Text(n).font(Theme.label(15)).foregroundStyle(.black)
                .frame(width: 30, height: 30).background(Theme.amber, in: Circle())
            (Text(a).foregroundStyle(Theme.textPrimary)
             + Text(hi).foregroundStyle(Theme.amber).bold()
             + Text(b).foregroundStyle(Theme.textPrimary))
                .font(Theme.body(17))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: Game
    private var game: some View {
        VStack(spacing: 16) {
            Text(badge)
                .font(Theme.label(13)).tracking(1.5)
                .foregroundStyle(isPractice ? Theme.amber : Theme.textSecondary)
                .padding(.horizontal, 16).padding(.vertical, 8)
                .background(.ultraThinMaterial, in: Capsule())
                .overlay(Capsule().strokeBorder(Theme.hairline, lineWidth: 1))
                .padding(.top, 52)
            Spacer()
            ZStack {
                RoundedRectangle(cornerRadius: 40, style: .continuous)
                    .fill(padColor)
                    .shadow(color: padColor.opacity(0.55), radius: 44)
                VStack(spacing: 10) {
                    Text(padBig).font(Theme.score(pad == .go ? 56 : 40)).foregroundStyle(padFg)
                    if !padSmall.isEmpty {
                        Text(padSmall).font(Theme.body(16)).foregroundStyle(padFg.opacity(0.85))
                            .multilineTextAlignment(.center).padding(.horizontal, 28)
                    }
                }
            }
            .frame(height: 360)
            .padding(.horizontal, Theme.pad)
            .contentShape(RoundedRectangle(cornerRadius: 40, style: .continuous))
            .onTapGesture { tapPad() }
            Spacer()
            if pad == .practiceDone {
                PrimaryButton(title: "Start for real →") {
                    isPractice = false; realDone = 0; times = []; arm()
                }
                .padding(.horizontal, Theme.pad)
            } else {
                Text(footer).font(Theme.body(15)).foregroundStyle(Theme.textSecondary)
                    .frame(height: 22)
            }
            Spacer().frame(height: 22)
        }
    }

    // MARK: copy / color
    private var badge: String {
        isPractice ? "PRACTICE ROUND" : "ROUND \(min(realDone + 1, realTotal)) OF \(realTotal)"
    }
    private var padColor: Color {
        switch pad {
        case .ready:        return Theme.surface2
        case .wait:         return Theme.deepHeat
        case .go:           return Theme.goGreen
        case .early:        return Theme.ember
        case .practiceDone, .roundDone: return Theme.amber
        }
    }
    private var padFg: Color { pad == .ready ? Theme.textPrimary : .black.opacity(0.85) }
    private var padBig: String {
        switch pad {
        case .ready:        return "Get ready…"
        case .wait:         return "Wait…"
        case .go:           return "TAP!"
        case .early:        return "Too early 😅"
        case .practiceDone: return "\(Int(lastMs)) ms"
        case .roundDone:    return "\(Int(lastMs)) ms"
        }
    }
    private var padSmall: String {
        switch pad {
        case .ready:        return "Wait for green, then tap"
        case .wait:         return "…don't tap yet"
        case .go:           return ""
        case .early:        return "No worries — tap to retry. This one doesn't count."
        case .practiceDone: return "Nice, that's the idea! That was just practice."
        case .roundDone:    return "Logged ⚡"
        }
    }
    private var footer: String {
        switch pad {
        case .go:        return "NOW!"
        case .roundDone: return "Nice"
        default:         return ""
        }
    }

    // MARK: logic
    private func startPractice() {
        withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) { started = true }
        isPractice = true
        arm()
    }

    private func arm() {
        pad = .ready
        token += 1
        let readyToken = token
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            guard readyToken == token else { return }
            pad = .wait
            let waitToken = token
            let delay = Double.random(in: 1.5...3.2)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                guard waitToken == token, pad == .wait else { return }
                greenAt = Date()
                pad = .go
                tap.toggle()
            }
        }
    }

    private func tapPad() {
        tap.toggle()
        switch pad {
        case .ready, .roundDone, .practiceDone:
            break
        case .wait:
            token += 1            // cancel the pending green
            pad = .early
        case .go:
            lastMs = greenAt.map { Date().timeIntervalSince($0) * 1000 } ?? 300
            if isPractice {
                pad = .practiceDone
            } else {
                times.append(lastMs)
                realDone += 1
                if realDone >= realTotal {
                    finish()
                } else {
                    pad = .roundDone
                    let t = token
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.95) {
                        guard t == token, pad == .roundDone else { return }
                        arm()
                    }
                }
            }
        case .early:
            arm()
        }
    }

    private func finish() {
        pad = .roundDone
        let mean = times.isEmpty ? 380 : times.reduce(0, +) / Double(times.count)
        let variance = times.isEmpty ? 0 : times.reduce(0) { $0 + pow($1 - mean, 2) } / Double(times.count)
        let lapse = min(1.5, sqrt(variance) / 250)
        let reaction = ReactionResult(meanMillis: mean, lapseVariance: lapse)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            app.finishOnboarding(quiz: quiz, reaction: reaction)
        }
    }
}
