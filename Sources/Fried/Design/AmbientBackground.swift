import SwiftUI

/// The signature "fried but classy" backdrop: soft heat-glow orbs bleeding up
/// from a warm-black void. Uses a GeometryReader + .position so the fixed-size
/// blurred orbs never dictate the layout size of the screen (which would push
/// content off the edges).
struct AmbientBackground: View {
    var tier: FriedTier? = nil

    var body: some View {
        let warm = tier.map { Theme.glowColor(for: $0) } ?? Theme.glow
        let cool = (tier == .crispMind) ? Theme.mint : Theme.ember
        ZStack {
            Theme.void
            GeometryReader { geo in
                ZStack {
                    Circle().fill(warm)
                        .frame(width: 520, height: 520)
                        .blur(radius: 130).opacity(0.22)
                        .position(x: geo.size.width * 0.86, y: geo.size.height * 0.10)
                    Circle().fill(cool)
                        .frame(width: 460, height: 460)
                        .blur(radius: 140).opacity(0.15)
                        .position(x: geo.size.width * 0.10, y: geo.size.height * 0.92)
                }
            }
        }
        .clipped()
        .ignoresSafeArea()
    }
}
