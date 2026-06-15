import Foundation

/// Produces the verdict line. Async so the on-device model can slot in later
/// (Phase 4) without touching callers. For now it always uses the curated,
/// guardrail-safe RoastBank — which is also the permanent fallback.
enum RoastEngine {
    static func roast(for score: FriedScore) async -> String {
        // Phase 4: try Apple's on-device FoundationModels here, fall back below.
        return RoastBank.roast(for: score.tier, seed: score.value)
    }
}
