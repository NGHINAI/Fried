import Foundation

/// Tracks which de-fry plan steps the user has checked off TODAY. Resets daily
/// (keyed by date). Turns the plan from "a list" into a daily program.
@MainActor
final class ChallengeStore: ObservableObject {
    @Published private(set) var done: Set<Int> = []
    private let cal = Calendar.current

    init() { load() }

    private var todayKey: String {
        let d = cal.startOfDay(for: Date())
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return "fried.challenge." + f.string(from: d)
    }

    func isDone(_ i: Int) -> Bool { done.contains(i) }

    func toggle(_ i: Int) {
        if done.contains(i) { done.remove(i) } else { done.insert(i) }
        UserDefaults.standard.set(Array(done), forKey: todayKey)
    }

    func completed(of total: Int) -> Int { done.filter { $0 < total }.count }

    private func load() {
        if let arr = UserDefaults.standard.array(forKey: todayKey) as? [Int] {
            done = Set(arr)
        }
    }
}
