import Foundation
#if canImport(FoundationModels)
import FoundationModels
#endif

/// Why Yolkie's on-device AI is or isn't running — surfaced in the UI so it's never
/// a mystery WHY replies are generic. The live AI needs: iOS 26+, an Apple-Intelligence
/// capable device (iPhone 15 Pro / 16 / 17), Apple Intelligence ON, and the model
/// downloaded. If any is missing we fall back to the (good) templated answers.
enum AIStatus {
    static var isAvailable: Bool {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            if case .available = SystemLanguageModel.default.availability { return true }
        }
        #endif
        return false
    }

    /// A short, user-facing explanation of the current state.
    static var line: String {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            switch SystemLanguageModel.default.availability {
            case .available:
                return "On-device AI active"
            case .unavailable(let reason):
                switch reason {
                case .deviceNotEligible:
                    return "Live AI needs an Apple Intelligence device (iPhone 15 Pro or newer)"
                case .appleIntelligenceNotEnabled:
                    return "Turn on Apple Intelligence in Settings to wake Yolkie's live AI"
                case .modelNotReady:
                    return "Apple Intelligence is still downloading — check back soon"
                @unknown default:
                    return "On-device AI is unavailable right now"
                }
            }
        } else {
            return "Yolkie's live AI needs iOS 26"
        }
        #else
        return "Yolkie's live AI needs iOS 26"
        #endif
    }
}
