import SwiftUI

/// Stub — built out in Phase 6 (daily score, de-fry streak, weekly trend).
struct HomeView: View {
    @EnvironmentObject var app: AppState
    var body: some View {
        VStack(spacing: 12) {
            Text("Home").font(Theme.title()).foregroundStyle(Theme.textPrimary)
            Text("Daily score · streak · trend — Phase 6")
                .font(Theme.body()).foregroundStyle(Theme.textSecondary)
        }
    }
}
