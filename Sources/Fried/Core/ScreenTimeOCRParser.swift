import Foundation

/// Pure parser: turns OCR'd text lines from a Screen Time screenshot into a
/// `ScreenTimeResult`. Kept free of Vision so it's unit-testable. The Vision
/// call lives in the feature layer and hands its recognized strings here.
enum ScreenTimeOCRParser {

    static func parse(_ lines: [String]) -> ScreenTimeResult {
        var total = 0
        var apps: [AppUsage] = []
        var pendingLabel: String? = nil

        for raw in lines {
            let line = raw.trimmingCharacters(in: .whitespaces)
            if line.isEmpty { continue }

            if let minutes = duration(in: line), minutes > 0 {
                let label = pendingLabel?.lowercased() ?? ""
                let isTotalish = pendingLabel == nil
                    || label.contains("total")
                    || label.contains("average")
                    || label.contains("screen time")
                if isTotalish {
                    total = max(total, minutes)
                } else {
                    apps.append(AppUsage(app: pendingLabel!, minutes: minutes))
                }
                pendingLabel = nil
            } else {
                pendingLabel = line
            }
        }
        return ScreenTimeResult(totalMinutes: total, apps: apps)
    }

    /// Parses durations like "6h 12m", "58m", "1h", "3 hr 42 min".
    static func duration(in line: String) -> Int? {
        let pattern = #"(?:(\d+)\s*h(?:r)?)?\s*(?:(\d+)\s*m(?:in)?)?"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        let ns = line as NSString
        for m in regex.matches(in: line, range: NSRange(location: 0, length: ns.length)) {
            let hRange = m.range(at: 1)
            let mRange = m.range(at: 2)
            let h = hRange.location != NSNotFound ? (Int(ns.substring(with: hRange)) ?? 0) : 0
            let mins = mRange.location != NSNotFound ? (Int(ns.substring(with: mRange)) ?? 0) : 0
            if h > 0 || mins > 0 { return h * 60 + mins }
        }
        return nil
    }
}
