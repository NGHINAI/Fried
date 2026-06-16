import Foundation
import UserNotifications

/// Schedules a daily local reminder to re-check your fried score — the #1
/// retention lever. Local notifications need no special entitlement.
enum NotificationManager {
    private static let id = "fried.daily"

    /// Asks permission and, if granted, schedules the daily reminder.
    static func requestAndSchedule() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let granted = (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
        if granted { schedule() }
        return granted
    }

    /// Re-schedule with the user's CURRENT state so the 7pm nudge is personal —
    /// the streak they're about to lose hits far harder than a generic ping.
    static func refresh(streak: Int, friedPercent: Int) async {
        guard await isAuthorized() else { return }
        schedule(streak: streak, friedPercent: friedPercent)
    }

    static func schedule(streak: Int = 0, friedPercent: Int = 0) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [id])

        let content = UNMutableNotificationContent()
        if streak >= 2 {
            content.title = "🔥 Your \(streak)-day streak ends tonight"
            content.body = "Your brain's frying again. One 60-second check keeps the streak alive."
        } else if friedPercent >= 60 {
            content.title = "Your brain is \(friedPercent)% fried 🍳"
            content.body = "It got crispier today. Take 60s to cool it down before bed."
        } else {
            content.title = "Your brain is frying 🍳"
            content.body = "It got crispier overnight. Take 60s to cool it down."
        }
        content.sound = .default

        var when = DateComponents()
        when.hour = 19   // 7pm local
        let trigger = UNCalendarNotificationTrigger(dateMatching: when, repeats: true)
        center.add(UNNotificationRequest(identifier: id, content: content, trigger: trigger))
    }

    static func cancel() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }

    static func isAuthorized() async -> Bool {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus == .authorized
    }

    /// True only if the user has never been asked — so we can show a benefit-first
    /// priming card before the one-shot system prompt (lifts opt-in materially).
    static func isUndetermined() async -> Bool {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus == .notDetermined
    }
}
