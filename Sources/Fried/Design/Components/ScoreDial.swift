import SwiftUI

/// Animated ring + counting numeral. Counts 0→score and fills the ring over ~1.3s.
/// Respects Reduce Motion (snaps to final value).
struct ScoreDial: View {
    let score: Int
    let tier: FriedTier
    var animate: Bool = true

    @State private var ringProgress: Double = 0
    @State private var displayNumber: Int = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            Circle().stroke(.white.opacity(0.06), lineWidth: 18)
            Circle()
                .trim(from: 0, to: ringProgress)
                .stroke(Theme.gradient(for: tier),
                        style: StrokeStyle(lineWidth: 18, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .shadow(color: Theme.color(for: tier).opacity(0.55), radius: 16)
            VStack(spacing: -4) {
                Text("\(displayNumber)")
                    .font(Theme.score(98))
                    .foregroundStyle(Theme.gradient(for: tier))
                    .monospacedDigit()
                    .contentTransition(.numericText())
                Text("/ 100").font(Theme.label(15)).foregroundStyle(Theme.textSecondary)
            }
        }
        .frame(width: 250, height: 250)
        .task(id: score) {
            guard animate && !reduceMotion else {
                ringProgress = Double(score) / 100
                displayNumber = score
                return
            }
            withAnimation(.easeOut(duration: 1.3)) { ringProgress = Double(score) / 100 }
            let per = UInt64(1_300_000_000 / UInt64(max(score, 1)))
            for v in 0...max(score, 0) {
                displayNumber = v
                try? await Task.sleep(nanoseconds: per)
            }
            displayNumber = score
        }
    }
}
