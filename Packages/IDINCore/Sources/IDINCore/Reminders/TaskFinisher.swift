import Foundation

/// Finishing a session outside the main UI — currently the "Save & Finish" action on
/// the long-run notification.
@MainActor
public enum TaskFinisher {
    /// Writes the running task to its calendar, then clears the shared running state.
    /// The calendar write happens first so a failure can never lose the session.
    @discardableResult
    public static func finishRunningTask(
        using manager: CalendarManager,
        fallbackCalendarID: String,
        endingAt end: Date = Date()
    ) throws -> RunningTask? {
        let sync = SyncManager.shared
        guard let task = sync.runningTask else { return nil }

        let calendarID = task.calendarIdentifier.isEmpty ? fallbackCalendarID : task.calendarIdentifier
        try manager.createEvent(
            title: task.text,
            start: task.startTime,
            end: end,
            calendarID: calendarID
        )

        sync.finish()
        return task
    }
}
