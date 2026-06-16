import SwiftUI

/// The "reading your brain" ceremony. A determinate copper ring + a checklist
/// that names the user's OWN inputs back to them (labor illusion + IKEA effect →
/// the score feels computed *about you*, not generic), a held "Analysis complete"
/// beat (the Zeigarnik suspense apex), then the reveal. ~5s, one-shot, never loops.
/// Research: Cal AI / Umax analysis screens + Norton & Buell labor illusion.
struct CalculatingView: View {
    @EnvironmentObject var app: AppState
    @State private var phase = -1
    @State private var ring: CGFloat = 0
    @State private var tick = 0
    @State private var done = false

    private var steps: [String] {
        ["Reading your \(app.quiz?.answerIndices.count ?? 6) answers",
         "Calibrating for age \(app.age)",
         "Comparing to 40,000 brains",
         "Calculating your Fry Score"]
    }
    private let holds: [Double] = [0.9, 0.9, 1.0, 1.6]          // last stage slowest = "the hard part"
    private let marks: [CGFloat] = [0.25, 0.5, 0.72, 1.0]

    var body: some View {
        ZStack {
            VStack(spacing: 38) {
                Spacer()
                ringHero
                ZStack {
                    if done { completeLabel } else { checklist }
                }
                .frame(height: 150)
                Spacer()
                Text("Reading your brain — don't close the app.")
                    .font(Theme.label(12)).foregroundStyle(Theme.textSecondary.opacity(0.6))
                    .opacity(done ? 0 : 1)
            }
            .padding(.horizontal, 36).padding(.bottom, 40)
        }
        .task { await run() }
        .sensoryFeedback(.impact(weight: .light, intensity: 0.6), trigger: tick)
        .sensoryFeedback(.success, trigger: done)
    }

    private var ringHero: some View {
        ZStack {
            Circle().stroke(Theme.amber.opacity(0.12), lineWidth: 7)
            Circle().trim(from: 0, to: ring)
                .stroke(Theme.heatGradient, style: StrokeStyle(lineWidth: 7, lineCap: .round))
                .rotationEffect(.degrees(-90))
            EggMascot(mood: done ? .proud : .curious, friedLevel: 0.35, size: 88)
                .scaleEffect(done ? 1.06 : 1)
        }
        .frame(width: 150, height: 150)
        .padding(26)
        .liquidGlass(in: Circle())
        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: done)
    }

    private var checklist: some View {
        VStack(alignment: .leading, spacing: 15) {
            ForEach(Array(steps.enumerated()), id: \.offset) { i, step in
                HStack(spacing: 12) {
                    stepIcon(i).frame(width: 22, height: 22)
                    Text(step)
                        .font(Theme.body(16))
                        .foregroundStyle(i <= phase ? Theme.textPrimary : Theme.textSecondary.opacity(0.4))
                    Spacer(minLength: 0)
                }
            }
        }
        .frame(maxWidth: 290)
        .transition(.opacity)
    }

    @ViewBuilder private func stepIcon(_ i: Int) -> some View {
        if i < phase {
            Image(systemName: "checkmark.circle.fill").font(.system(size: 19)).foregroundStyle(Theme.amber)
        } else if i == phase {
            ProgressView().controlSize(.small).tint(Theme.amber)
        } else {
            Image(systemName: "circle").font(.system(size: 17)).foregroundStyle(Theme.textSecondary.opacity(0.3))
        }
    }

    private var completeLabel: some View {
        VStack(spacing: 8) {
            Image(systemName: "checkmark.seal.fill").font(.system(size: 30)).foregroundStyle(Theme.amber)
            Text("Analysis complete").font(Theme.title(23)).foregroundStyle(Theme.textPrimary)
            Text("Your brain has been read.").font(Theme.body(15)).foregroundStyle(Theme.textSecondary)
        }
        .transition(.opacity.combined(with: .scale(scale: 0.92)))
    }

    private func run() async {
        for i in 0..<steps.count {
            withAnimation(.easeInOut(duration: 0.3)) { phase = i }
            withAnimation(.easeInOut(duration: holds[i])) { ring = marks[i] }
            try? await Task.sleep(nanoseconds: UInt64(holds[i] * 1_000_000_000))
            tick += 1                                   // a light tick as each line lands
        }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) { done = true }
        try? await Task.sleep(nanoseconds: 750_000_000)  // the suspense beat
        withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) { app.screen = .reveal }
    }
}
