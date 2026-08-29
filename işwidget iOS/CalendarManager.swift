import Foundation
import EventKit

@Observable
class CalendarManager {
    private let store = EKEventStore()
    private static let calendarKey = "selectedCalendarIdentifier"

    var calendars: [EKCalendar] = []
    var selectedCalendar: EKCalendar?
    var accessDenied = false

    func requestAccess() async {
        do {
            let granted = try await store.requestFullAccessToEvents()
            if granted {
                fetchCalendars()
            } else {
                accessDenied = true
            }
        } catch {
            accessDenied = true
        }
    }

    private func fetchCalendars() {
        calendars = store.calendars(for: .event).filter { $0.allowsContentModifications }
        let savedId = UserDefaults.standard.string(forKey: Self.calendarKey)
        selectedCalendar = calendars.first(where: { $0.calendarIdentifier == savedId }) ?? calendars.first
    }

    func saveSelectedCalendar() {
        UserDefaults.standard.set(selectedCalendar?.calendarIdentifier, forKey: Self.calendarKey)
    }

    func calendar(for identifier: String) -> EKCalendar? {
        calendars.first(where: { $0.calendarIdentifier == identifier }) ?? calendars.first
    }

    func createEvent(title: String, startDate: Date, endDate: Date, calendar: EKCalendar) throws {
        let event = EKEvent(eventStore: store)
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.calendar = calendar
        try store.save(event, span: .thisEvent)
    }
}
