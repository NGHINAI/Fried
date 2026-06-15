import SwiftUI

/// The signature "fried but classy" backdrop: soft heat-glow orbs bleeding up
/// from a warm-black void, so frosted-glass cards on top look lit-from-within.
/// Optionally tints to the current tier on the reveal.
struct AmbientBackground: View {
    var tier: FriedTier? = nil

    var body: some View {
        let warm = tier.map { Theme.glowColor(for: $0) } ?? Theme.glow
        let cool = (tier == .crispMind) ? Theme.mint : Theme.ember
        ZStack {
            Theme.void
            Circle().fill(warm)
                .frame(width: 500, height: 500)
                .blur(radius: 130)
                .opacity(0.22)
                .offset(x: 150, y: -300)
            Circle().fill(cool)
                .frame(width: 440, height: 440)
                .blur(radius: 140)
                .opacity(0.15)
                .offset(x: -160, y: 360)
        }
        .ignoresSafeArea()
    }
}
