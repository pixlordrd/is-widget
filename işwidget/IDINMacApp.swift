import SwiftUI
import IDINCore

@main
struct IDINMacApp: App {
    static let aboutWindowID = "idin-about"

    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State private var settings = AppSettings()
    @Environment(\.openWindow) private var openWindow

    var body: some Scene {
        Window(Brand.name, id: "idin-widget") {
            ContentView(settings: settings)
                .idinTheme(settings.theme)
                .background(WidgetWindowConfigurator())
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultSize(width: 320, height: 260)
        .commands {
            // Replace the stock About panel with IDIN's own.
            CommandGroup(replacing: .appInfo) {
                Button("About \(Brand.name)") {
                    openWindow(id: Self.aboutWindowID)
                }
            }
        }

        Window("About \(Brand.name)", id: Self.aboutWindowID) {
            AboutView()
                .idinTheme(settings.theme)
        }
        .windowResizability(.contentSize)
        .defaultPosition(.center)
    }
}
