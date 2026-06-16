import SwiftUI

struct RootView: View {
    @StateObject private var app = AppState()
    @StateObject private var store = Store()
    @StateObject private var history = HistoryStore()
    @StateObject private var challenge = ChallengeStore()
    @StateObject private var brain = BrainState()
    @StateObject private var reportStore = ReportStore()
    @StateObject private var archetypeStore = ArchetypeStore()
    @StateObject private var askStore = AskStore()
    @StateObject private var router = TabRouter()

    var body: some View {
        ZStack {
            AmbientBackground(tier: app.screen == .reveal ? app.result?.tier : nil)
            content
        }
        .environmentObject(app)
        .environmentObject(store)
        .environmentObject(history)
        .environmentObject(challenge)
        .environmentObject(brain)
        .environmentObject(reportStore)
        .environmentObject(archetypeStore)
        .environmentObject(askStore)
        .environmentObject(router)
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
