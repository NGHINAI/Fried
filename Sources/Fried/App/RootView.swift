import SwiftUI

struct RootView: View {
    @StateObject private var app = AppState()
    @StateObject private var store = Store()
    @StateObject private var history = HistoryStore()
    @StateObject private var challenge = ChallengeStore()

    var body: some View {
        ZStack {
            AmbientBackground(tier: app.screen == .reveal ? app.result?.tier : nil)
            content
        }
        .environmentObject(app)
        .environmentObject(store)
        .environmentObject(history)
        .environmentObject(challenge)
        .preferredColorScheme(.dark)
    }

    @ViewBuilder private var content: some View {
        switch app.screen {
        case .splash:      SplashView()
        case .onboarding:  OnboardingFlow()
        case .calculating: CalculatingView()
        case .reveal:      RevealView()
        case .home:        MainTabView()
        case .paywall:     PaywallView()
        }
    }
}
