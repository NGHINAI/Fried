import SwiftUI

struct CalculatingView: View {
    @EnvironmentObject var app: AppState
    @State private var i = 0
    @State private var spin = false

    private let lines = [
        "Measuring your scroll velocity…",
        "Tallying up the doomscrolls…",
        "Consulting the algorithm…",
        "Plating your results…"
    ]

    var body: some View {
        VStack(spacing: 26) {
            Spacer()
            EggMascot(mood: .curious, size: 96)
                .rotationEffect(.degrees(spin ? 8 : -8))
                .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: spin)
            Text(lines[min(i, lines.count - 1)])
                .font(Theme.body(18))
                .foregroundStyle(Theme.textSecondary)
                .id(i)
                .transition(.opacity)
            Spacer()
        }
        .onAppear { spin = true }
        .task {
            for n in 0..<lines.count {
                withAnimation(.easeInOut) { i = n }
                try? await Task.sleep(nanoseconds: 650_000_000)
            }
            try? await Task.sleep(nanoseconds: 400_000_000)
            withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) { app.screen = .reveal }
        }
    }
}
