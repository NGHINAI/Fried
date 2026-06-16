import SwiftUI

struct SplashView: View {
    @EnvironmentObject var app: AppState
    @State private var appear = false

    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            EggMascot(mood: .curious, size: 116)
                .scaleEffect(appear ? 1 : 0.6)
                .opacity(appear ? 1 : 0)
            Text("fried")
                .font(.system(size: 66, weight: .regular, design: .default))
                .foregroundStyle(Theme.textPrimary)
                .tracking(-1)
            Text("How fried is your brain?")
                .font(Theme.body(17))
                .foregroundStyle(Theme.textSecondary)
                .tracking(0.2)
            Spacer()
            PrimaryButton(title: "Find out", subtitle: "60 seconds · no sign-up") {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                    app.screen = .onboarding
                }
            }
            .padding(.horizontal, Theme.pad)
            Text("A playful vibe check, just for fun.")
                .font(.system(size: 12, weight: .regular, design: .rounded))
                .foregroundStyle(Theme.textSecondary.opacity(0.7))
                .padding(.bottom, 10)
        }
        .onAppear { withAnimation(.easeOut(duration: 0.7)) { appear = true } }
    }
}
