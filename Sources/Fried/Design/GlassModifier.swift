import SwiftUI

/// Refined dark glass: a darkened frosted panel with a thin top-lit hairline —
/// the premium, understated Reticla look (not bright Liquid Glass).
struct MaterialGlass: ViewModifier {
    let cornerRadius: CGFloat
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous).fill(.ultraThinMaterial)
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous).fill(Color.black.opacity(0.30))
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous).fill(Color.white.opacity(0.02))
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(
                        LinearGradient(colors: [Color.white.opacity(0.14), Color.white.opacity(0.03)],
                                       startPoint: .top, endPoint: .bottom),
                        lineWidth: 1)
            )
    }
}

extension View {
    func friedGlass(cornerRadius: CGFloat = 18) -> some View {
        modifier(MaterialGlass(cornerRadius: cornerRadius))
    }

    /// Genuine iOS 26 **Liquid Glass** — used ONLY on the floating layer (CTA bars,
    /// the analysis ring, chips), never on the dark content cards (glass-on-glass
    /// goes muddy — Apple HIG). Falls back to a top-lit frosted material on iOS 18.
    @ViewBuilder
    func liquidGlass(in shape: some Shape = Capsule(), tint: Color? = nil, interactive: Bool = false) -> some View {
        if #available(iOS 26.0, *) {
            glassEffect(Self.liquidStyle(tint: tint, interactive: interactive), in: shape)
        } else {
            background(
                ZStack {
                    shape.fill(.ultraThinMaterial)
                    shape.fill(Color.black.opacity(0.22))
                    shape.fill(LinearGradient(colors: [.white.opacity(0.16), .clear],
                                              startPoint: .topLeading, endPoint: .bottomTrailing))
                }
            )
            .overlay(shape.stroke(.white.opacity(0.14), lineWidth: 1))
        }
    }

    @available(iOS 26.0, *)
    private static func liquidStyle(tint: Color?, interactive: Bool) -> Glass {
        var g: Glass = .regular
        if let tint { g = g.tint(tint) }
        if interactive { g = g.interactive() }
        return g
    }
}
