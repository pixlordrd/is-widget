import SwiftUI
import UserNotifications
import IDINCore

@main
struct IDINApp: App {
    @AppStorage("iOSTheme") private var themeName = AppTheme.system.rawValue

    init() {
        UNUserNotificationCenter.current().delegate = ReminderResponder.shared
        ReminderNotifications.registerCategory()
    }

    private var theme: AppTheme {
        AppTheme(rawValue: themeName) ?? .system
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .idinTheme(theme)
        }
    }
}
