import SwiftUI

/// Lightweight, dependency-free confetti burst for the score reveal "wow".
/// Pieces start above the screen and rain down once `burst` flips to true.
struct ConfettiView: View {
    var burst: Bool
    private let count = 80
    private let colors: [Color] = [Theme.amber, Theme.ember, Theme.glow, Theme.mint, .white]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(0..<count, id: \.self) { i in
                    piece(i, geo)
                }
            }
        }
        .allowsHitTesting(false)
    }

    private func piece(_ i: Int, _ geo: GeometryProxy) -> some View {
        let s = Double(i)
        let x = rnd(s, 1)
        let delay = rnd(s, 2) * 0.6
        let spin = rnd(s, 3)
        let size = 5 + rnd(s, 4) * 7
        let drift = (rnd(s, 5) - 0.5) * 80
        let color = colors[i % colors.count]
        let duration = 1.7 + rnd(s, 6) * 1.4

        return RoundedRectangle(cornerRadius: 2)
            .fill(color)
            .frame(width: size, height: size * 1.7)
            .position(x: x * geo.size.width + (burst ? drift : 0),
                      y: burst ? geo.size.height + 40 : -30)
            .rotationEffect(.degrees(burst ? 360 * spin * 4 : 0))
            .animation(.linear(duration: duration).delay(delay), value: burst)
    }

    /// Deterministic pseudo-random in 0...1 from a seed + salt.
    private func rnd(_ seed: Double, _ salt: Double) -> Double {
        let v = sin(seed * 12.9898 + salt * 78.233) * 43758.5453
        return v - floor(v)
    }
}
