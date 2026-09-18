#if canImport(ActivityKit) && os(iOS)
import ActivityKit
import Foundation

/// Starts and ends the Dynamic Island / Lock Screen activity for a running session.
///
/// ActivityKit only lets an app start an activity from the foreground, so a session
/// that began on the Mac gets its activity the next time the iPhone app is opened —
/// `sync(with:)` handles that catch-up.
/// Not main-actor isolated on purpose: ActivityKit's `Activity` isn't `Sendable`, so
/// everything that touches one has to stay inside a single, non-main isolation domain.
public enum LiveActivityController {
    public static var isAvailable: Bool {
        ActivityAuthorizationInfo().areActivitiesEnabled
    }

    private static var current: Activity<IDINActivityAttributes>? {
        Activity<IDINActivityAttributes>.activities.first
    }

    /// Brings activities in line with the shared running task.
    public static func sync(with task: RunningTask?) async {
        guard let task else {
            await end()
            return
        }

        guard isAvailable else { return }

        let state = IDINActivityAttributes.ContentState(task: task)

        if let activity = current {
            // A task already showing: update in place rather than restarting, so the
            // island doesn't flicker when the text changed on another device.
            guard activity.content.state != state else { return }
            await activity.update(ActivityContent(state: state, staleDate: nil))
            return
        }

        do {
            _ = try Activity.request(
                attributes: IDINActivityAttributes(),
                content: ActivityContent(state: state, staleDate: nil),
                pushType: nil
            )
        } catch {
            // Denied in Settings, started from the background, or too many activities —
            // none of these should disturb the app.
        }
    }

    public static func end() async {
        for activity in Activity<IDINActivityAttributes>.activities {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
    }
}
#endif
