import SwiftUI

/// Subtle, premium backdrop: a neutral near-black base with one faint warm
/// glow — understated (Reticla-style), not the old loud heat orbs.
struct AmbientBackground: View {
    var tier: FriedTier? = nil

    var body: some View {
        let warm = tier.map { Theme.glowColor(for: $0) } ?? Theme.glow
        ZStack {
            Theme.void
            GeometryReader { geo in
                ZStack {
                    Circle().fill(warm)
                        .frame(width: 560, height: 560)
                        .blur(radius: 170).opacity(0.10)
                        .position(x: geo.size.width * 0.80, y: geo.size.height * 0.05)
                    Circle().fill(Color.white)
                        .frame(width: 320, height: 320)
                        .blur(radius: 190).opacity(0.022)
                        .position(x: geo.size.width * 0.18, y: geo.size.height * 0.88)
                }
            }
        }
        .clipped()
        .ignoresSafeArea()
    }
}
