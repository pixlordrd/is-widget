import Foundation
import UserNotifications
import IDINCore

/// Handles the buttons on the long-run reminder notification, including when the app
/// is only woken in the background.
final class ReminderResponder: NSObject, UNUserNotificationCenterDelegate {
    static let shared = ReminderResponder()

    /// Show the banner even while IDIN is in the foreground — the in-app prompt and the
    /// notification cover different cases, and this keeps the sound consistent.
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        await handle(actionID: response.actionIdentifier)
    }

    @MainActor
    private func handle(actionID: String) async {
        guard let task = SyncManager.shared.runningTask else {
            ReminderNotifications.cancel()
            return
        }

        let preferences = ReminderPreferences.shared

        switch actionID {
        case ReminderNotifications.continueActionID:
            // Ask again after one more interval.
            await ReminderNotifications.schedule(
                for: task,
                after: preferences.interval,
                thresholdText: preferences.thresholdText
            )

        case ReminderNotifications.finishActionID:
            let manager = CalendarManager()
            await manager.requestAccess()
            let fallback = UserDefaults.standard.string(forKey: "selectedCalendarID") ?? ""
            try? TaskFinisher.finishRunningTask(using: manager, fallbackCalendarID: fallback)
            ReminderNotifications.cancel()

        default:
            // Tapping the banner just opens the app; ContentView raises the prompt.
            break
        }
    }
}
