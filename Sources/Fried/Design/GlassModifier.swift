import SwiftUI

/// Frosted-material glass with a gradient hairline ("light catching the edge").
struct MaterialGlass: ViewModifier {
    let cornerRadius: CGFloat
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous).fill(.ultraThinMaterial)
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(Color(red: 1, green: 0.96, blue: 0.92).opacity(0.05))
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(
                        LinearGradient(colors: [Color.white.opacity(0.20), Color.white.opacity(0.04)],
                                       startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: 1)
            )
    }
}

/// Real iOS 26 Liquid Glass (specular highlights + live blur).
@available(iOS 26.0, *)
struct NativeGlass: ViewModifier {
    let cornerRadius: CGFloat
    func body(content: Content) -> some View {
        content.glassEffect(in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

extension View {
    /// Native Liquid Glass on iOS 26+, frosted-material fallback below.
    @ViewBuilder
    func friedGlass(cornerRadius: CGFloat = 18) -> some View {
        if #available(iOS 26.0, *) {
            modifier(NativeGlass(cornerRadius: cornerRadius))
        } else {
            modifier(MaterialGlass(cornerRadius: cornerRadius))
        }
    }
}
