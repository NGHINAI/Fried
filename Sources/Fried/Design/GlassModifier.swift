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
}
