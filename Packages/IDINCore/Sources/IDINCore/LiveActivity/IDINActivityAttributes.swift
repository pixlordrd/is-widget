// ActivityKit imports on macOS but `ActivityAttributes` is iOS-only, so gate on the
// platform rather than on the module.
#if os(iOS)
import ActivityKit
import Foundation

/// Live Activity payload for a running session.
///
/// The elapsed time is *not* part of the state: the widget renders it from
/// `startTime` with a self-updating timer, so a running session needs zero updates
/// and therefore no push server and no background work.
public struct IDINActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable, Sendable {
        public var text: String
        public var startTime: Date

        public init(text: String, startTime: Date) {
            self.text = text
            self.startTime = startTime
        }
    }

    public init() {}
}

public extension IDINActivityAttributes.ContentState {
    init(task: RunningTask) {
        self.init(text: task.text, startTime: task.startTime)
    }
}
#endif
