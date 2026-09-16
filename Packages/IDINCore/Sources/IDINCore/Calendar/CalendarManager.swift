import EventKit
import Observation

/// Calendar access and event writing. A finished task becomes one EKEvent.
@MainActor
@Observable
public final class CalendarManager {
    private let store = EKEventStore()

    /// Calendars the user is allowed to write into.
    public private(set) var calendars: [EKCalendar] = []
    public private(set) var accessDenied = false

    public init() {}

    /// Identifier of the calendar to use when the user has not chosen one yet.
    public var defaultCalendarID: String? {
        store.defaultCalendarForNewEvents?.calendarIdentifier ?? calendars.first?.calendarIdentifier
    }

    public func requestAccess() async {
        do {
            if try await store.requestFullAccessToEvents() {
                reloadCalendars()
                accessDenied = false
            } else {
                accessDenied = true
            }
        } catch {
            accessDenied = true
        }
    }

    public func calendar(id: String) -> EKCalendar? {
        calendars.first { $0.calendarIdentifier == id } ?? store.defaultCalendarForNewEvents
    }

    /// Writes a finished task into the calendar it was started with.
    public func createEvent(title: String, start: Date, end: Date, calendarID: String) throws {
        guard let calendar = calendar(id: calendarID) else { throw CalendarError.noWritableCalendar }

        let event = EKEvent(eventStore: store)
        event.title = title
        event.startDate = start
        event.endDate = max(end, start)
        event.calendar = calendar
        try store.save(event, span: .thisEvent)
    }

    private func reloadCalendars() {
        calendars = store.calendars(for: .event)
            .filter(\.allowsContentModifications)
            .sorted { $0.title.localizedStandardCompare($1.title) == .orderedAscending }
    }

    public enum CalendarError: LocalizedError {
        case noWritableCalendar

        public var errorDescription: String? {
            switch self {
            case .noWritableCalendar: "No writable calendar is available."
            }
        }
    }
}
