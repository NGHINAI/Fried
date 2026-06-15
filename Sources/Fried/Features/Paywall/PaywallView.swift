import SwiftUI

/// Stub — built out in Phase 5 (StoreKit 2 lifetime unlock, teaser gating).
struct PaywallView: View {
    @EnvironmentObject var app: AppState
    var body: some View {
        VStack(spacing: 18) {
            Text("Unlock Fried").font(Theme.title()).foregroundStyle(Theme.textPrimary)
            Text("$4.99 once · no subscription — Phase 5")
                .font(Theme.body()).foregroundStyle(Theme.textSecondary)
            Button("Back") { app.screen = .reveal }
                .font(Theme.body()).foregroundStyle(Theme.heatTop)
        }
    }
}
