import SwiftUI

/// "Yolkie" — the fried-egg mascot. Drawn in pure SwiftUI so it scales crisply
/// and can emote based on the user's score (the research's #1 onboarding theme:
/// a character that reacts pulls users deeper).
enum EggMood { case chill, curious, worried, shocked, fried, proud }

extension EggMood {
    static func forTier(_ tier: FriedTier) -> EggMood {
        switch tier {
        case .crispMind:      return .proud
        case .lightlyToasted: return .chill
        case .wellDone:       return .worried
        case .extraCrispy:    return .shocked
        case .deepFried:      return .fried
        }
    }
}

struct EggMascot: View {
    var mood: EggMood = .curious
    var size: CGFloat = 130
    @State private var bob = false

    var body: some View {
        ZStack {
            eggWhite
            yolk
            face
        }
        .frame(width: size, height: size)
        .offset(y: bob ? -size * 0.03 : size * 0.03)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) { bob = true }
        }
    }

    private var eggWhite: some View {
        ZStack {
            Circle().frame(width: size * 0.9, height: size * 0.9)
            Circle().frame(width: size * 0.46, height: size * 0.46).offset(x: -size * 0.4, y: size * 0.06)
            Circle().frame(width: size * 0.4, height: size * 0.4).offset(x: size * 0.4, y: -size * 0.1)
            Circle().frame(width: size * 0.42, height: size * 0.42).offset(x: size * 0.12, y: size * 0.4)
            Circle().frame(width: size * 0.34, height: size * 0.34).offset(x: -size * 0.22, y: size * 0.36)
        }
        .foregroundStyle(Color(red: 0.98, green: 0.97, blue: 0.95))
        .shadow(color: .black.opacity(0.35), radius: size * 0.08, y: size * 0.03)
    }

    private var yolk: some View {
        Circle()
            .fill(LinearGradient(colors: [Theme.glow, Theme.amber, Theme.ember],
                                 startPoint: .top, endPoint: .bottom))
            .frame(width: size * 0.58, height: size * 0.58)
            .overlay(
                Circle().fill(.white.opacity(0.35))
                    .frame(width: size * 0.1, height: size * 0.1)
                    .offset(x: -size * 0.12, y: -size * 0.13)
            )
    }

    private var face: some View {
        VStack(spacing: size * 0.05) {
            HStack(spacing: size * 0.13) { eye; eye }
            mouth.frame(width: size * 0.2, height: size * 0.1)
        }
    }

    @ViewBuilder private var eye: some View {
        switch mood {
        case .shocked:
            Circle().stroke(.black, lineWidth: size * 0.018)
                .background(Circle().fill(.white))
                .frame(width: size * 0.11, height: size * 0.11)
                .overlay(Circle().fill(.black).frame(width: size * 0.05, height: size * 0.05))
        case .fried:
            ZStack {
                Capsule().fill(.black).frame(width: size * 0.13, height: size * 0.022).rotationEffect(.degrees(45))
                Capsule().fill(.black).frame(width: size * 0.13, height: size * 0.022).rotationEffect(.degrees(-45))
            }
            .frame(width: size * 0.12, height: size * 0.12)
        case .proud:
            Capsule().fill(.black).frame(width: size * 0.09, height: size * 0.05)   // happy arc-ish
        default:
            Capsule().fill(.black).frame(width: size * 0.065, height: size * 0.1)
        }
    }

    @ViewBuilder private var mouth: some View {
        switch mood {
        case .proud, .chill:  MouthCurve(curve: 0.7).stroke(.black, style: .init(lineWidth: size * 0.022, lineCap: .round))
        case .worried, .fried: MouthCurve(curve: -0.6).stroke(.black, style: .init(lineWidth: size * 0.022, lineCap: .round))
        case .shocked:        Circle().fill(.black).frame(width: size * 0.08, height: size * 0.08)
        case .curious:        MouthCurve(curve: 0.15).stroke(.black, style: .init(lineWidth: size * 0.022, lineCap: .round))
        }
    }
}

private struct MouthCurve: Shape {
    var curve: CGFloat   // + smile, − frown
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX, y: rect.midY))
        p.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.midY),
                       control: CGPoint(x: rect.midX, y: rect.midY + curve * rect.height))
        return p
    }
}

/// A glass speech bubble for the mascot to "talk".
struct SpeechBubble: View {
    let text: String
    var body: some View {
        Text(text)
            .font(Theme.body(16)).foregroundStyle(Theme.textPrimary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 18).padding(.vertical, 13)
            .friedGlass(cornerRadius: 20)
    }
}
