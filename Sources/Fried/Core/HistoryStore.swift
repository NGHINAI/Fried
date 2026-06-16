import Foundation

struct DayScore: Codable, Identifiable {
    let date: Date
    let value: Int
    var id: TimeInterval { date.timeIntervalSince1970 }
}

/// Persists daily Fried scores (UserDefaults) and computes the de-fry streak.
@MainActor
final class HistoryStore: ObservableObject {
    @Published private(set) var days: [DayScore] = []
    private let key = "fried.history.v1"
    private let cal = Calendar.current

    init() { load() }

    func record(_ value: Int) {
        let today = cal.startOfDay(for: Date())
        var arr = days.filter { !cal.isDate($0.date, inSameDayAs: today) }
        arr.append(DayScore(date: today, value: value))
        arr.sort { $0.date < $1.date }
        days = Array(arr.suffix(30))
        save()
    }

    var last7: [DayScore] { Array(days.suffix(7)) }

    /// Consecutive calendar days with a recorded score, counting back from today
    /// (or yesterday, so a fresh morning doesn't break it).
    var streak: Int {
        let set = Set(days.map { cal.startOfDay(for: $0.date) })
        guard !set.isEmpty else { return 0 }
        var cursor = cal.startOfDay(for: Date())
        if !set.contains(cursor) {
            guard let y = cal.date(byAdding: .day, value: -1, to: cursor), set.contains(y) else { return 0 }
            cursor = y
        }
        var count = 0
        while set.contains(cursor) {
            count += 1
            guard let prev = cal.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = prev
        }
        return count
    }

    /// The longest run of consecutive days ever recorded — a lifetime stat to protect.
    var longestStreak: Int {
        let set = Set(days.map { cal.startOfDay(for: $0.date) }).sorted()
        guard !set.isEmpty else { return 0 }
        var longest = 1, run = 1
        for i in 1..<set.count {
            if let next = cal.date(byAdding: .day, value: 1, to: set[i - 1]),
               cal.isDate(next, inSameDayAs: set[i]) {
                run += 1; longest = max(longest, run)
            } else { run = 1 }
        }
        return longest
    }

    /// Demo data so the trend chart looks alive in previews/screenshots.
    func seedSampleIfEmpty() {
        guard days.isEmpty else { return }
        let today = cal.startOfDay(for: Date())
        let vals = [88, 84, 86, 79, 81, 76, 73]
        days = vals.enumerated().compactMap { i, v in
            cal.date(byAdding: .day, value: i - 6, to: today).map { DayScore(date: $0, value: v) }
        }
    }

    private func load() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([DayScore].self, from: data) {
            days = decoded
        }
    }
    private func save() {
        if let data = try? JSONEncoder().encode(days) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
