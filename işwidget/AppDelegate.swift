import AppKit
import IDINCore

/// Guards against losing an in-progress session: closing or quitting while a task
/// is running asks for confirmation first.
@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    private var isAsking = false
    private var quitConfirmed = false
    private let menuBar = MenuBarController()

    func applicationDidFinishLaunching(_ notification: Notification) {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(windowBecameKey(_:)),
            name: NSWindow.didBecomeKeyNotification,
            object: nil
        )

        menuBar.onToggleWindow = { [weak self] in self?.toggleWidgetWindow() }
        menuBar.install()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { true }

    /// Clicking the Dock icon brings the widget back when it's parked in the menu bar.
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag { showWidgetWindow() }
        return true
    }

    // MARK: Menu bar

    private var widgetWindow: NSWindow? {
        NSApp.windows.first { $0.identifier == NSWindow.widgetIdentifier }
    }

    private func toggleWidgetWindow() {
        guard let window = widgetWindow else { return }

        if window.isVisible, !window.isMiniaturized {
            window.orderOut(nil)
        } else {
            showWidgetWindow()
        }
    }

    private func showWidgetWindow() {
        guard let window = widgetWindow else { return }
        NSApp.activate()
        window.deminiaturize(nil)
        window.makeKeyAndOrderFront(nil)
    }

    // MARK: Window delegate

    @objc private func windowBecameKey(_ notification: Notification) {
        // Only the floating widget window needs the delegate — not panels (alerts,
        // sheets) and not the About window, whose close must never prompt to quit.
        guard let window = notification.object as? NSWindow,
              !(window is NSPanel),
              window.identifier == NSWindow.widgetIdentifier else { return }
        window.delegate = self
    }

    /// Closing the widget window always asks first — the red dot is easy to hit by
    /// accident, and a running session would be lost.
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        guard !isAsking else { return false }

        isAsking = true
        makeQuitAlert().beginSheetModal(for: sender) { [weak self] response in
            self?.isAsking = false
            if response == .alertFirstButtonReturn {
                self?.quitConfirmed = true
                NSApp.terminate(nil)
            }
        }
        return false
    }

    /// Minimizing parks IDIN in the menu bar rather than the Dock — for a window that
    /// floats over everything, the menu bar is where you look for it.
    func windowDidMiniaturize(_ notification: Notification) {
        guard let window = notification.object as? NSWindow,
              window.identifier == NSWindow.widgetIdentifier else { return }

        window.deminiaturize(nil)
        window.orderOut(nil)
    }

    // MARK: Termination

    /// ⌘Q asks too, whether or not a task is running.
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        if quitConfirmed { return .terminateNow }
        guard !isAsking else { return .terminateCancel }

        isAsking = true
        let response = makeQuitAlert().runModal()
        isAsking = false
        return response == .alertFirstButtonReturn ? .terminateNow : .terminateCancel
    }

    private func makeQuitAlert() -> NSAlert {
        let alert = NSAlert()
        alert.addButton(withTitle: String(localized: "OK"))
        alert.addButton(withTitle: String(localized: "Cancel"))
        alert.messageText = String(localized: "Quit \(Brand.name)?")

        if let task = SyncManager.shared.runningTask {
            alert.informativeText = String(
                localized: "“\(task.text)” is still running — quitting now will not write this session to your calendar."
            )
            alert.alertStyle = .warning
        } else {
            alert.informativeText = String(localized: "Are you sure you want to quit?")
            alert.alertStyle = .informational
        }

        return alert
    }
}
