import Foundation
#if canImport(FoundationModels)
import FoundationModels
#endif

struct DailyReport: Codable, Equatable {
    let day: String          // yyyy-MM-dd
    let headline: String
    let reading: String      // the smart, AI-personalized centerpiece
    let risk: String         // Low / Medium / High
    let mission: String
    let sig: String          // signature of the inputs it was built from
}

/// Everything the report is personalized from.
struct ReportContext {
    let score: FriedScore
    let realAge: Int
    let brainAge: Int
    let freshness: Double
    let streak: Int
    let reaction: ReactionResult?
    let topLeak: String?
    let weekday: Int         // 1=Sun … 7=Sat
    let daySeed: Int
}

/// Generates today's report: ONE on-device AI call for the personalized reading
/// (cached per day), with a deterministic, day-varying fallback so every device
/// gets something genuinely fresh daily.
enum ReportEngine {
    static func make(_ ctx: ReportContext) async -> DailyReport {
        let risk = riskLevel(ctx)
        let mission = mission(ctx)
        let headline = headline(ctx, risk: risk)
        var reading = templateReading(ctx, risk: risk)
        if #available(iOS 26.0, *) {
            if let ai = await aiReading(ctx, risk: risk) { reading = ai }
        }
        return DailyReport(day: Self.dayKey(), headline: headline, reading: reading,
                           risk: risk, mission: mission, sig: signature(ctx))
    }

    static func dayKey(_ date: Date = Date()) -> String {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }

    /// The inputs the report's wording actually cites. If any change (e.g. a
    /// mid-day re-test, or passive decay ticking brain age up), the report
    /// regenerates so the card and the report never show different numbers.
    static func signature(_ ctx: ReportContext) -> String {
        "\(ctx.score.value)|\(ctx.brainAge)|\(Int(ctx.freshness))|\(ctx.streak)"
    }

    // MARK: On-device AI (the smart reading)
    @available(iOS 26.0, *)
    private static func aiReading(_ ctx: ReportContext, risk: String) async -> String? {
        #if canImport(FoundationModels)
        let model = SystemLanguageModel.default
        guard case .available = model.availability else { return nil }
        let session = LanguageModelSession {
            """
            You are Yolkie — a witty, slightly dramatic fried-egg mascot who gives \
            someone a short DAILY "brain report." Be personal to the exact numbers \
            you're given, a little alarming about how fried they are, but warm and \
            end on a hopeful nudge. 2–3 sentences, second person ("you"), PG-13. \
            Never claim medical/scientific facts or mention real cognition, IQ, or \
            health conditions. Output only the report text — no preamble, no quotes.
            """
        }
        let opts = GenerationOptions(temperature: 1.1, maximumResponseTokens: 120)
        let prompt = """
        Today's data — fried score \(ctx.score.value)/100 (\(ctx.score.tier.title)); \
        brain age \(ctx.brainAge) vs real age \(ctx.realAge); brain freshness \
        \(Int(ctx.freshness))/100; \(ctx.streak)-day streak; \
        reflexes \(ctx.reaction.map { "\(Int($0.meanMillis))ms" } ?? "unknown"); \
        biggest habit: \(ctx.topLeak ?? "scrolling"); today's doomscroll risk: \(risk). \
        Write today's brain report.
        """
        do {
            let r = try await session.respond(to: prompt, options: opts)
            let text = r.content.trimmingCharacters(in: CharacterSet(charactersIn: " \n\"'"))
            return text.isEmpty ? nil : text
        } catch { return nil }
        #else
        return nil
        #endif
    }

    // MARK: Deterministic, day-varying structure
    private static func riskLevel(_ ctx: ReportContext) -> String {
        var s = Double(ctx.score.value) * 0.5 + (100 - ctx.freshness) * 0.3
        if ctx.weekday == 1 || ctx.weekday == 7 { s += 14 }   // weekends = more scrolling
        s += Double(ctx.daySeed % 18) - 9
        switch s {
        case 62...:    return "High"
        case 38..<62:  return "Medium"
        default:       return "Low"
        }
    }

    private static func headline(_ ctx: ReportContext, risk: String) -> String {
        let crisp = ["Fresh start.", "Holding the line.", "Sharper than yesterday?"]
        let mid   = ["The feed is circling.", "Crispy around the edges.", "You're warming up."]
        let fried = ["You're deep-frying.", "Code red, chef.", "The algorithm is winning."]
        let pool = ctx.freshness > 66 ? crisp : (ctx.freshness > 33 ? mid : fried)
        return pool[ctx.daySeed % pool.count]
    }

    private static func mission(_ ctx: ReportContext) -> String {
        let pool = [
            "Phone in another room for one full hour today.",
            "No screens for the first 30 minutes after you wake up.",
            "One 25-minute focus block, phone face-down.",
            "Greyscale your phone until lunch.",
            "Swap one scroll session for a 10-minute walk.",
            "Delete your worst app from the home screen for the day."
        ]
        if let leak = ctx.topLeak, leak.lowercased().contains("short") {
            return "Cap short-form video at 20 minutes today."
        }
        return pool[ctx.daySeed % pool.count]
    }

    private static func templateReading(_ ctx: ReportContext, risk: String) -> String {
        let gap = ctx.brainAge - ctx.realAge
        let agePart = gap >= 6
            ? "Your brain's clocking in at \(ctx.brainAge) today — \(gap) years past your actual age. "
            : (gap <= -1 ? "Your brain's running young today (\(ctx.brainAge)). Rare. " : "Your brain age sits right around \(ctx.brainAge). ")
        let statePart = ctx.freshness < 35
            ? "You're \(ctx.friedPercentText) fried and it's still dropping. "
            : "You're holding at \(Int(ctx.freshness))/100 freshness. "
        let riskPart = risk == "High"
            ? "High doomscroll risk today — the feed will come for you."
            : (risk == "Medium" ? "Medium risk today. Stay sharp." : "Low risk today. Good window to reset.")
        return agePart + statePart + riskPart
    }
}

private extension ReportContext {
    var friedPercentText: String { "\(Int((100 - freshness).rounded()))%" }
}

/// Holds today's report; generates once per day and caches it.
@MainActor
final class ReportStore: ObservableObject {
    @Published private(set) var report: DailyReport?
    @Published private(set) var loading = false
    private let key = "fried.report.v2"

    init() {
        if let data = UserDefaults.standard.data(forKey: key),
           let r = try? JSONDecoder().decode(DailyReport.self, from: data),
           r.day == ReportEngine.dayKey() {
            report = r
        }
    }

    func ensure(_ ctx: @autoclosure () -> ReportContext) async {
        let context = ctx()
        let sig = ReportEngine.signature(context)
        if let report, report.day == ReportEngine.dayKey(), report.sig == sig { return }
        loading = true
        let r = await ReportEngine.make(context)
        report = r
        if let data = try? JSONEncoder().encode(r) { UserDefaults.standard.set(data, forKey: key) }
        loading = false
    }
}
