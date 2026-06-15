import SwiftUI

/// Frosted glass surface (native Liquid Glass on iOS 26). The ambient heat-glow
/// behind it bleeds through, for the lit-from-within look.
struct GlassCard<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .friedGlass(cornerRadius: Theme.radius)
            .shadow(color: .black.opacity(0.4), radius: 22, y: 10)
    }
}
