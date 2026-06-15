import SwiftUI

struct RootView: View {
    @StateObject private var app = AppState()

    var body: some View {
        ZStack {
            Theme.canvas.ignoresSafeArea()
            content
        }
        .environmentObject(app)
        .preferredColorScheme(.dark)
    }

    @ViewBuilder private var content: some View {
        switch app.screen {
        case .splash:      SplashView()
        case .onboarding:  OnboardingFlow()
        case .calculating: CalculatingView()
        case .reveal:      RevealView()
        case .home:        HomeView()
        case .paywall:     PaywallView()
        }
    }
}
