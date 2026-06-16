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

    static func schedule() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [id])

        let content = UNMutableNotificationContent()
        content.title = "Your brain is frying 🍳"
        content.body = "It got crispier overnight. Take 60s to cool it down."
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
}
