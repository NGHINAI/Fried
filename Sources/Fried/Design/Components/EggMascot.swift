import SwiftUI

/// "Yolkie" — the fried-egg mascot. Emotes by mood, and physically BURNS as
/// `friedLevel` rises (0 = fresh white, 1 = charred). It's the user's brain.
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
    static func forFreshness(_ f: Double) -> EggMood {
        switch f {
        case 75...:   return .proud
        case 55..<75: return .chill
        case 38..<55: return .worried
        case 20..<38: return .shocked
        default:      return .fried
        }
    }
}

struct EggMascot: View {
    var mood: EggMood = .curious
    var friedLevel: Double = 0      // 0 fresh … 1 charred
    var size: CGFloat = 130
    @State private var bob = false

    private var t: Double { min(1, max(0, friedLevel)) }

    var body: some View {
        ZStack {
            eggWhite
            yolk
            charSpots
            face
        }
        .frame(width: size, height: size)
        .offset(y: bob ? -size * 0.03 : size * 0.03)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) { bob = true }
        }
    }

    private func lerp(_ a: (Double, Double, Double), _ b: (Double, Double, Double), _ k: Double) -> Color {
        Color(red: a.0 + (b.0 - a.0) * k, green: a.1 + (b.1 - a.1) * k, blue: a.2 + (b.2 - a.2) * k)
    }

    private var eggWhite: some View {
        ZStack {
            Ellipse().frame(width: size * 0.98, height: size * 0.80)
            Circle().frame(width: size * 0.5, height: size * 0.5).offset(x: -size * 0.33, y: size * 0.17)
            Circle().frame(width: size * 0.42, height: size * 0.42).offset(x: size * 0.36, y: -size * 0.05)
            Circle().frame(width: size * 0.34, height: size * 0.34).offset(x: size * 0.14, y: size * 0.32)
        }
        .foregroundStyle(lerp((0.965, 0.96, 0.95), (0.42, 0.34, 0.26), t))
        .shadow(color: .black.opacity(0.32), radius: size * 0.07, y: size * 0.025)
    }

    private var yolk: some View {
        let burnt = (0.20, 0.12, 0.08)
        return Circle()
            .fill(LinearGradient(colors: [
                lerp((0.902, 0.627, 0.455), burnt, t),
                lerp((0.851, 0.549, 0.361), burnt, t),
                lerp((0.761, 0.420, 0.290), burnt, t)
            ], startPoint: .top, endPoint: .bottom))
            .frame(width: size * 0.58, height: size * 0.58)
            .overlay(
                Circle().fill(.white.opacity(0.35 * (1 - t)))
                    .frame(width: size * 0.1, height: size * 0.1)
                    .offset(x: -size * 0.12, y: -size * 0.13)
            )
    }

    @ViewBuilder private var charSpots: some View {
        if t > 0.55 {
            ZStack {
                Circle().fill(Color.black.opacity(0.35)).frame(width: size * 0.09, height: size * 0.09)
                    .offset(x: -size * 0.32, y: size * 0.22)
                Circle().fill(Color.black.opacity(0.30)).frame(width: size * 0.07, height: size * 0.07)
                    .offset(x: size * 0.34, y: size * 0.12)
                Circle().fill(Color.black.opacity(0.28)).frame(width: size * 0.06, height: size * 0.06)
                    .offset(x: size * 0.18, y: size * 0.34)
            }
            .opacity((t - 0.55) / 0.45)
        }
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
            Capsule().fill(.black).frame(width: size * 0.09, height: size * 0.05)
        default:
            Capsule().fill(.black).frame(width: size * 0.065, height: size * 0.1)
        }
    }

    @ViewBuilder private var mouth: some View {
        switch mood {
        case .proud, .chill:   MouthCurve(curve: 0.7).stroke(.black, style: .init(lineWidth: size * 0.022, lineCap: .round))
        case .worried, .fried: MouthCurve(curve: -0.6).stroke(.black, style: .init(lineWidth: size * 0.022, lineCap: .round))
        case .shocked:         Circle().fill(.black).frame(width: size * 0.08, height: size * 0.08)
        case .curious:         MouthCurve(curve: 0.15).stroke(.black, style: .init(lineWidth: size * 0.022, lineCap: .round))
        }
    }
}

private struct MouthCurve: Shape {
    var curve: CGFloat
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX, y: rect.midY))
        p.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.midY),
                       control: CGPoint(x: rect.midX, y: rect.midY + curve * rect.height))
        return p
    }
}

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
