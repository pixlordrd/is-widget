import Foundation
import Observation

/// Real-time running-task sync between macOS and iOS via the iCloud key-value store.
///
/// Both platforms read `runningTask` directly — neither keeps its own copy of the
/// running state, so Start on one device immediately drives the other's UI.
///
/// The storage keys are intentionally the same as IDIN 1.x so an existing user's
/// running task survives the upgrade.
@MainActor
@Observable
public final class SyncManager {
    public static let shared = SyncManager()

    private enum Key {
        static let runningTask = "idin_runningTask"
        static let lastTaskText = "idin_lastTaskText"
    }

    private let store = NSUbiquitousKeyValueStore.default

    /// The task currently being tracked on any of the user's devices.
    public private(set) var runningTask: RunningTask?

    /// Title of the most recently finished task, offered as a one-tap restart.
    public private(set) var lastTaskText: String?

    private init() {
        loadTask()

        // `queue: .main` guarantees main-thread delivery, so hopping back onto the
        // main actor without an await is safe here.
        NotificationCenter.default.addObserver(
            forName: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: store,
            queue: .main
        ) { _ in
            MainActor.assumeIsolated {
                SyncManager.shared.handleExternalChange()
            }
        }

        store.synchronize()
    }

    // MARK: Mutations

    /// Starts tracking a task and publishes it to the user's other devices.
    public func start(_ text: String, calendarID: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let task = RunningTask(text: trimmed, startTime: Date(), calendarIdentifier: calendarID)
        guard let data = try? JSONEncoder().encode(task) else { return }

        store.set(data, forKey: Key.runningTask)
        store.synchronize()
        runningTask = task
    }

    /// Stops tracking and returns the finished task so the caller can write it to a calendar.
    @discardableResult
    public func finish() -> RunningTask? {
        guard let task = runningTask else { return nil }

        store.set(task.text, forKey: Key.lastTaskText)
        store.removeObject(forKey: Key.runningTask)
        store.synchronize()

        runningTask = nil
        lastTaskText = task.text
        return task
    }

    /// Clears the running task without recording it — used when the user discards a session.
    public func cancel() {
        store.removeObject(forKey: Key.runningTask)
        store.synchronize()
        runningTask = nil
    }

    // MARK: Loading

    /// Re-reads the store. Only assigns on change so SwiftUI does not refresh needlessly.
    public func loadTask() {
        let stored: RunningTask? = store.data(forKey: Key.runningTask)
            .flatMap { try? JSONDecoder().decode(RunningTask.self, from: $0) }

        if stored != runningTask {
            runningTask = stored
        }

        let storedLast = store.string(forKey: Key.lastTaskText)
        if storedLast != lastTaskText {
            lastTaskText = storedLast
        }
    }

    private func handleExternalChange() {
        store.synchronize()
        loadTask()
    }
}
