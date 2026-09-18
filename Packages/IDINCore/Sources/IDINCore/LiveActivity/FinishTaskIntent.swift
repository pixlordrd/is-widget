#if canImport(AppIntents) && os(iOS)
import AppIntents
import Foundation

/// The Done button inside the Live Activity: writes the session to the calendar and
/// clears the running state without opening the app.
public struct FinishTaskIntent: LiveActivityIntent {
    public static let title: LocalizedStringResource = "Save & Finish"
    public static let description = IntentDescription("Saves the running task to your calendar and stops the timer.")

    /// Keeps the button responsive in the island instead of bouncing into the app.
    public static let openAppWhenRun = false

    public init() {}

    public func perform() async throws -> some IntentResult {
        let manager = await CalendarManager()
        await manager.requestAccess()

        let fallbackCalendarID = UserDefaults.standard.string(forKey: "selectedCalendarID") ?? ""

        try await MainActor.run {
            try TaskFinisher.finishRunningTask(using: manager, fallbackCalendarID: fallbackCalendarID)
        }

        await LiveActivityController.end()
        return .result()
    }
}
#endif
