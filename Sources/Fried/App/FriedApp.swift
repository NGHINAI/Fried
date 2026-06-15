import SwiftUI

@main
struct FriedApp: App {
    var body: some Scene {
        WindowGroup {
            RootPlaceholderView()
        }
    }
}

/// Phase-0 placeholder so the project builds + runs. Replaced by RootView in Phase 3.
struct RootPlaceholderView: View {
    var body: some View {
        ZStack {
            Color(red: 0.04, green: 0.04, blue: 0.04).ignoresSafeArea()
            Text("fried")
                .font(.system(size: 72, weight: .heavy, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color(red: 1.0, green: 0.69, blue: 0.13),
                            Color(red: 1.0, green: 0.23, blue: 0.18)
                        ],
                        startPoint: .top, endPoint: .bottom
                    )
                )
        }
    }
}
