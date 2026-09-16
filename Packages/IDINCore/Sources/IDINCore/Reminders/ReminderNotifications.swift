#if canImport(UserNotifications)
import UserNotifications

/// Local notification that asks "keep going or save it now?" when a session runs long.
/// Needed because the app may be backgrounded when the threshold passes.
public enum ReminderNotifications {
    public static let categoryID = "IDIN_LONG_RUN"
    public static let continueActionID = "IDIN_CONTINUE"
    public static let finishActionID = "IDIN_FINISH"
    private static let requestID = "IDIN_LONG_RUN_REQUEST"

    /// Registers the two-button category. Call once at launch.
    public static func registerCategory() {
        let keepGoing = UNNotificationAction(
            identifier: continueActionID,
            title: "Keep Going",
            options: []
        )
        let finish = UNNotificationAction(
            identifier: finishActionID,
            title: "Save & Finish",
            options: [.authenticationRequired]
        )
        let category = UNNotificationCategory(
            identifier: categoryID,
            actions: [keepGoing, finish],
            intentIdentifiers: [],
            options: []
        )
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }

    @discardableResult
    public static func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound])
        } catch {
            return false
        }
    }

    /// Schedules (or replaces) the reminder for a running task.
    public static func schedule(for task: RunningTask, after interval: TimeInterval, thresholdText: String) async {
        cancel()
        guard interval > 0 else { return }

        let settings = await UNUserNotificationCenter.current().notificationSettings()
        guard settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional else { return }

        let content = UNMutableNotificationContent()
        content.title = "Still on it?"
        content.body = "You've passed \(thresholdText) on “\(task.text)”. Keep going, or save it to your calendar now?"
        content.sound = .default
        content.categoryIdentifier = categoryID
        // `.timeSensitive` would need the Time Sensitive Notifications entitlement,
        // which would have to be added to the provisioning profile first.
        content.interruptionLevel = .active

        let request = UNNotificationRequest(
            identifier: requestID,
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
        )

        try? await UNUserNotificationCenter.current().add(request)
    }

    public static func cancel() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [requestID])
        center.removeDeliveredNotifications(withIdentifiers: [requestID])
    }
}
#endif
