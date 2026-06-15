import SwiftUI

/// Frosted glass surface: blur + a whisper-warm tint + hairline edge + soft shadow.
/// The ambient heat-glow behind it bleeds through the frost (lit-from-within look).
struct GlassCard<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: Theme.radius, style: .continuous)
                        .fill(.ultraThinMaterial)
                    RoundedRectangle(cornerRadius: Theme.radius, style: .continuous)
                        .fill(Color(red: 1.0, green: 0.96, blue: 0.92).opacity(0.04))
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.radius, style: .continuous)
                    .strokeBorder(Theme.hairline, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.45), radius: 24, y: 10)
    }
}
