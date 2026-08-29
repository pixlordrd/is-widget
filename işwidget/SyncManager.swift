import Foundation

struct RunningTaskInfo: Codable, Equatable {
    var text: String
    var startTime: Date
    var calendarIdentifier: String
}

/// Real-time task sync between macOS and iOS via iCloud KV Store.
@Observable
class SyncManager {
    private static let taskKey = "idin_runningTask"
    private static let lastTaskKey = "idin_lastTaskText"
    private let store = NSUbiquitousKeyValueStore.default

    var runningTask: RunningTaskInfo?
    var lastTaskText: String?

    init() {
        loadTask()
        NotificationCenter.default.addObserver(
            forName: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: store,
            queue: .main
        ) { [weak self] _ in
            self?.loadTask()
        }
        store.synchronize()
    }

    func startTask(text: String, calendarIdentifier: String) {
        let info = RunningTaskInfo(text: text, startTime: Date(), calendarIdentifier: calendarIdentifier)
        if let data = try? JSONEncoder().encode(info) {
            store.set(data, forKey: Self.taskKey)
            store.synchronize()
        }
        runningTask = info
    }

    func stopTask() {
        if let text = runningTask?.text {
            store.set(text, forKey: Self.lastTaskKey)
            lastTaskText = text
        }
        store.removeObject(forKey: Self.taskKey)
        store.synchronize()
        runningTask = nil
    }

    private func loadTask() {
        if let data = store.data(forKey: Self.taskKey),
           let info = try? JSONDecoder().decode(RunningTaskInfo.self, from: data) {
            runningTask = info
        } else {
            runningTask = nil
        }
        lastTaskText = store.string(forKey: Self.lastTaskKey)
    }
}
