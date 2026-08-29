import SwiftUI
import AppKit

@main
struct idinApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultSize(width: 320, height: 260)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    private var isShowingConfirmation = false
    private var closeConfirmed = false

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Pencere oluşturulunca delegate'i ata (NSPanel alertlerini atla)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(windowBecameKey(_:)),
            name: NSWindow.didBecomeKeyNotification,
            object: nil
        )
    }

    @objc private func windowBecameKey(_ notification: Notification) {
        guard let window = notification.object as? NSWindow,
              !(window is NSPanel) else { return }
        window.delegate = self
    }

    // Kırmızı X: sheet olarak göster (re-entrancy'yi önler)
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        guard !isShowingConfirmation else { return false }
        isShowingConfirmation = true
        let alert = makeAlert()
        alert.beginSheetModal(for: sender) { [weak self] response in
            self?.isShowingConfirmation = false
            if response == .alertFirstButtonReturn {
                self?.closeConfirmed = true
                NSApp.terminate(nil)
            }
        }
        return false
    }

    // Cmd+Q
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        if closeConfirmed { return .terminateNow }
        guard !isShowingConfirmation else { return .terminateCancel }
        isShowingConfirmation = true
        let response = makeAlert().runModal()
        isShowingConfirmation = false
        return response == .alertFirstButtonReturn ? .terminateNow : .terminateCancel
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }

    private func makeAlert() -> NSAlert {
        let alert = NSAlert()
        alert.messageText = "Quit IDIN"
        alert.informativeText = "Are you sure you want to quit?"
        alert.addButton(withTitle: "Quit")
        alert.addButton(withTitle: "Cancel")
        alert.alertStyle = .warning
        return alert
    }
}
