import Foundation
import Observation

/// Watches the running task and raises a prompt once it passes the configured
/// threshold: "you've passed 1 hr on this — keep going, or save it now?"
///
/// On macOS this also plays the chosen system sound. On iOS the app may be in the
/// background when the threshold passes, which is what the scheduled local
/// notification covers.
@MainActor
@Observable
public final class LongRunMonitor {
    private let preferences: ReminderPreferences

    /// Set when the threshold has passed and the user has not answered yet.
    public private(set) var overdueTask: RunningTask?

    private var countdown: Task<Void, Never>?
    private var armedStart: Date?
    private var snoozeCount = 0

    public init(preferences: ReminderPreferences = .shared) {
        self.preferences = preferences
    }

    /// Call on appear and whenever the running task changes.
    public func update(for task: RunningTask?) {
        countdown?.cancel()
        countdown = nil

        guard let task else {
            overdueTask = nil
            armedStart = nil
            snoozeCount = 0
            return
        }

        // A different session resets any snoozing.
        if armedStart != task.startTime {
            armedStart = task.startTime
            snoozeCount = 0
            overdueTask = nil
        }

        guard preferences.isEnabled else {
            overdueTask = nil
            return
        }

        arm(for: task)
    }

    /// User chose to continue — ask again after one more interval.
    public func keepGoing() {
        guard let task = overdueTask else { return }
        overdueTask = nil
        snoozeCount += 1
        arm(for: task)
    }

    /// User answered (finished, or dismissed) — stop prompting for this round.
    public func dismiss() {
        overdueTask = nil
    }

    /// Seconds until the next prompt for this task, used to schedule notifications.
    public func secondsUntilNextPrompt(for task: RunningTask, from now: Date = Date()) -> TimeInterval {
        deadline(for: task).timeIntervalSince(now)
    }

    private func deadline(for task: RunningTask) -> Date {
        task.startTime.addingTimeInterval(preferences.interval * Double(snoozeCount + 1))
    }

    private func arm(for task: RunningTask) {
        let wait = deadline(for: task).timeIntervalSinceNow

        // Already past the threshold (e.g. the app was reopened much later).
        guard wait > 0 else {
            fire(task)
            return
        }

        countdown = Task { [weak self] in
            try? await Task.sleep(for: .seconds(wait))
            guard !Task.isCancelled else { return }
            self?.fire(task)
        }
    }

    private func fire(_ task: RunningTask) {
        overdueTask = task
        preferences.sound.play()
    }
}
