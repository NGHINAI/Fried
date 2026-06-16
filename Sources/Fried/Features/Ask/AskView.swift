import SwiftUI

/// "Ask your brain" — the conversational AI wow. Elegant dark chat: Yolkie on the
/// left (glass), you on the right (copper), suggestion chips that bait curiosity,
/// a Liquid-Glass input. 5 free questions, then the paywall replaces the input.
struct AskView: View {
    var embedded = false                    // true when hosted as the Yolkie tab (no close button)
    @EnvironmentObject var app: AppState
    @EnvironmentObject var store: Store
    @EnvironmentObject var brain: BrainState
    @EnvironmentObject var history: HistoryStore
    @EnvironmentObject var ask: AskStore
    @Environment(\.dismiss) private var dismiss
    @State private var input = ""
    @FocusState private var focused: Bool

    private var score: FriedScore { app.result ?? FriedScore(value: 0, tier: .crispMind) }
    private var breakdown: BrainBreakdown {
        BrainBreakdownEngine.make(quiz: app.quiz, reaction: app.reaction, screenTime: app.screenTime,
                                  overall: score.value, age: app.age)
    }
    private var brainAge: Int {
        BrainAgeEngine.brainAge(realAge: app.age, score: score, reaction: app.reaction, freshness: brain.freshness)
    }
    private let suggestions = ["Why am I so fried?", "What's my #1 problem?", "How do I fix it?", "Roast me 🔥"]

    var body: some View {
        ZStack {
            Theme.void.ignoresSafeArea()
            AmbientBackground()
            VStack(spacing: 0) {
                topBar
                aiStatusLine
                messages
                inputArea
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            syncContext()
            #if DEBUG
            if ProcessInfo.processInfo.environment["FRIED_PREVIEW_ASK"] == "seed", ask.messages.isEmpty {
                ask.messages = [
                    AskMessage(role: .user, text: "Why am I so fried?"),
                    AskMessage(role: .brain, text: "You're 63% fried — more cooked than 85% of people your age — and it traces mostly to scroll pull. It's not permanent, but every day you ignore it, it sets a little deeper. Cool it down below before it sticks."),
                    AskMessage(role: .user, text: "How do I fix it?"),
                    AskMessage(role: .brain, text: "Start with your biggest leak: scroll pull. Do one de-fry mission today and re-test tonight. Small and daily beats heroic and never — that's how you claw the years back. Lock in a goal so you've got a finish line.")
                ]
                ask.lastReplyWasAI = false
            }
            #endif
        }
    }

    private var topBar: some View {
        HStack(spacing: 11) {
            if !embedded {
                Button { dismiss() } label: {
                    Image(systemName: "xmark").font(.system(size: 14, weight: .bold)).foregroundStyle(Theme.textSecondary)
                        .frame(width: 34, height: 34).liquidGlass(in: Circle(), interactive: true)
                }
                .buttonStyle(.plain)
            }
            AnimatedYolkie(size: 34, fried: Double(score.value) / 100, active: ask.thinking)
            VStack(alignment: .leading, spacing: 0) {
                Text("Yolkie").font(Theme.title(19)).foregroundStyle(Theme.textPrimary)
                Text(store.hasAccess ? "your brain coach · unlimited"
                                     : "\(ask.remaining(hasAccess: false)) free questions left")
                    .font(Theme.label(11)).foregroundStyle(store.hasAccess ? Theme.textSecondary : Theme.amber)
            }
            Spacer()
            if !ask.messages.isEmpty {
                Button { withAnimation { ask.clear() } } label: {
                    Image(systemName: "square.and.pencil").font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Theme.textSecondary).frame(width: 34, height: 34)
                        .liquidGlass(in: Circle(), interactive: true)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, Theme.pad).padding(.top, embedded ? 14 : 10).padding(.bottom, 10)
    }

    // The honest, definitive signal: only known AFTER a real call. availability can
    // say "available" while respond() still fails (Simulator, model still downloading).
    @ViewBuilder private var aiStatusLine: some View {
        if let wasAI = ask.lastReplyWasAI {
            Label(wasAI ? "Live on-device AI" : "Templated reply · live AI isn't running on this device",
                  systemImage: wasAI ? "bolt.fill" : "exclamationmark.triangle.fill")
                .font(Theme.label(11)).foregroundStyle(wasAI ? Theme.mint : Theme.amber)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Theme.pad).padding(.bottom, 8)
                .frame(maxWidth: .infinity)
        }
    }

    private var messages: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 14) {
                    if ask.messages.isEmpty { emptyState }
                    ForEach(ask.messages) { bubble($0) }
                    if ask.thinking { thinkingBubble }
                    Color.clear.frame(height: 1).id("bottom")
                }
                .padding(.horizontal, Theme.pad).padding(.vertical, 10)
            }
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: ask.messages.count) { _, _ in withAnimation { proxy.scrollTo("bottom", anchor: .bottom) } }
            .onChange(of: ask.thinking) { _, _ in withAnimation { proxy.scrollTo("bottom", anchor: .bottom) } }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            AnimatedYolkie(size: 104, fried: Double(score.value) / 100)
            Text("Hey, I'm Yolkie.").font(Theme.title(24)).foregroundStyle(Theme.textPrimary)
            Text("I've seen your numbers. Ask me anything about your brain — I'll give it to you straight.")
                .font(Theme.body(15)).foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center).padding(.horizontal, 24)
            Label(AIStatus.line, systemImage: AIStatus.isAvailable ? "bolt.fill" : "exclamationmark.circle.fill")
                .font(Theme.label(12)).foregroundStyle(AIStatus.isAvailable ? Theme.mint : Theme.amber)
                .padding(.horizontal, 12).padding(.vertical, 6)
                .background((AIStatus.isAvailable ? Theme.mint : Theme.amber).opacity(0.12), in: Capsule())
                .multilineTextAlignment(.center)
            VStack(spacing: 9) {
                ForEach(suggestions, id: \.self) { s in
                    Button { send(s) } label: {
                        HStack {
                            Text(s).font(Theme.body(15)).foregroundStyle(Theme.textPrimary)
                            Spacer()
                            Image(systemName: "arrow.up.right").font(.system(size: 12, weight: .bold))
                                .foregroundStyle(Theme.amber)
                        }
                        .padding(.horizontal, 16).padding(.vertical, 13)
                        .frame(maxWidth: .infinity).friedGlass(cornerRadius: 15)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top, 8)
        }
        .padding(.top, 36)
    }

    private func bubble(_ m: AskMessage) -> some View {
        HStack(alignment: .top, spacing: 9) {
            if m.role == .brain {
                EggMascot(mood: .chill, friedLevel: Double(score.value) / 100, size: 28).padding(.top, 2)
                Text(m.text).font(Theme.body(15)).foregroundStyle(Theme.textPrimary)
                    .padding(14).frame(maxWidth: 268, alignment: .leading).friedGlass(cornerRadius: 18)
                Spacer(minLength: 8)
            } else {
                Spacer(minLength: 8)
                Text(m.text).font(Theme.body(15)).foregroundStyle(.black)
                    .padding(14).frame(maxWidth: 268, alignment: .trailing)
                    .background(Theme.heatGradient, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
        }
        .frame(maxWidth: .infinity, alignment: m.role == .brain ? .leading : .trailing)
        .transition(.move(edge: m.role == .brain ? .leading : .trailing).combined(with: .opacity))
    }

    private var thinkingBubble: some View {
        HStack(spacing: 9) {
            AnimatedYolkie(size: 28, fried: Double(score.value) / 100, active: true)
            TypingDots().padding(.horizontal, 16).padding(.vertical, 15).friedGlass(cornerRadius: 18)
            Spacer(minLength: 8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder private var inputArea: some View {
        Group {
            if ask.canAsk(hasAccess: store.hasAccess) {
                HStack(spacing: 10) {
                    TextField("Ask your brain…", text: $input, axis: .vertical)
                        .focused($focused).font(Theme.body(16)).foregroundStyle(Theme.textPrimary)
                        .lineLimit(1...4).tint(Theme.amber)
                        .padding(.horizontal, 18).padding(.vertical, 13)
                        .liquidGlass(in: Capsule())
                    Button { send(input) } label: {
                        Image(systemName: "arrow.up").font(.system(size: 17, weight: .bold)).foregroundStyle(.black)
                            .frame(width: 46, height: 46).background(Theme.heatGradient, in: Circle())
                    }
                    .buttonStyle(.plain)
                    .disabled(input.trimmingCharacters(in: .whitespaces).isEmpty || ask.thinking)
                    .opacity(input.trimmingCharacters(in: .whitespaces).isEmpty || ask.thinking ? 0.45 : 1)
                }
                .padding(.horizontal, Theme.pad).padding(.top, 10).padding(.bottom, 12)
            } else {
                outOfRequests
            }
        }
        .background(.ultraThinMaterial)
    }

    private var outOfRequests: some View {
        VStack(spacing: 10) {
            Text("You're out of free questions").font(Theme.title(18)).foregroundStyle(Theme.textPrimary)
            Text("Yolkie has a lot more to say about your brain — and exactly how to fix it.")
                .font(Theme.body(14)).foregroundStyle(Theme.textSecondary).multilineTextAlignment(.center)
            PrimaryButton(title: "Unlock unlimited", subtitle: "\(store.fullPriceText) · one-time · no subscription") {
                dismiss()
                app.paywallReturn = .home
                withAnimation { app.screen = .paywall }
            }
        }
        .padding(.horizontal, Theme.pad).padding(.top, 14).padding(.bottom, 12)
    }

    private func send(_ text: String) {
        let q = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty, ask.canAsk(hasAccess: store.hasAccess) else { return }
        input = ""; focused = false
        syncContext()
        Task { await ask.ask(q, hasAccess: store.hasAccess) }
    }

    private func syncContext() {
        ask.context = AskContext(
            score: score.value, tier: score.tier.title,
            brainAge: brainAge, realAge: app.age,
            friedPercent: brain.friedPercent, percentile: breakdown.percentile,
            topLeak: breakdown.topLeak.label, streak: history.streak, goal: app.goal)
    }
}

/// A cartoonish, always-alive Yolkie — a gentle bob + wobble (snappier when active).
struct AnimatedYolkie: View {
    var size: CGFloat
    var fried: Double
    var mood: EggMood = .curious
    var active = false
    @State private var bob = false
    var body: some View {
        EggMascot(mood: mood, friedLevel: fried, size: size)
            .scaleEffect(bob ? 1.05 : 0.96)
            .rotationEffect(.degrees(bob ? 3 : -3))
            .offset(y: bob ? -3 : 2)
            .animation(.easeInOut(duration: active ? 0.4 : 1.2).repeatForever(autoreverses: true), value: bob)
            .onAppear { bob = true }
    }
}

private struct TypingDots: View {
    @State private var phase = 0
    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<3, id: \.self) { i in
                Circle().fill(Theme.textSecondary).frame(width: 7, height: 7)
                    .opacity(phase == i ? 1 : 0.3)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: phase)
        .task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(0.35))
                phase = (phase + 1) % 3
            }
        }
    }
}
