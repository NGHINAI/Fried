import SwiftUI

/// The heat-gradient primary CTA, with medium haptic on tap.
struct PrimaryButton: View {
    let title: String
    var subtitle: String? = nil
    let action: () -> Void
    @State private var trigger = false

    var body: some View {
        Button {
            trigger.toggle()
            action()
        } label: {
            VStack(spacing: 2) {
                Text(title).font(Theme.body(18)).fontWeight(.bold)
                if let subtitle {
                    Text(subtitle).font(Theme.label(12)).opacity(0.8)
                }
            }
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 17)
            .background(Theme.heatGradientH, in: Capsule())
            .shadow(color: Theme.heatBottom.opacity(0.4), radius: 14, y: 6)
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.impact(weight: .medium), trigger: trigger)
    }
}
