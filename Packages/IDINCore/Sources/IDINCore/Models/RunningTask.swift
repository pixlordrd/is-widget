import Foundation

/// The task that is currently being worked on, shared across devices via iCloud.
public struct RunningTask: Codable, Equatable, Sendable {
    public var text: String
    public var startTime: Date
    public var calendarIdentifier: String

    public init(text: String, startTime: Date, calendarIdentifier: String) {
        self.text = text
        self.startTime = startTime
        self.calendarIdentifier = calendarIdentifier
    }

    public func elapsed(until date: Date = Date()) -> TimeInterval {
        max(0, date.timeIntervalSince(startTime))
    }

    /// Human-readable elapsed time, e.g. "1 hr 4 min".
    public func elapsedText(until date: Date = Date()) -> String {
        Duration.seconds(elapsed(until: date))
            .formatted(.units(allowed: [.hours, .minutes], width: .abbreviated))
    }
}
