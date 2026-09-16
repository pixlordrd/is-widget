import AppKit
import IDINCore

/// Guards against losing an in-progress session: closing or quitting while a task
/// is running asks for confirmation first.
@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    private var isAsking = false
    private var quitConfirmed = false

    func applicationDidFinishLaunching(_ notification: Notification) {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(windowBecameKey(_:)),
            name: NSWindow.didBecomeKeyNotification,
            object: nil
        )
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { true }

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
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")

        if let task = SyncManager.shared.runningTask {
            alert.messageText = "Quit \(Brand.name)?"
            alert.informativeText = "“\(task.text)” is still running — quitting now will not write this session to your calendar."
            alert.alertStyle = .warning
        } else {
            alert.messageText = "Quit \(Brand.name)?"
            alert.informativeText = "Are you sure you want to quit?"
            alert.alertStyle = .informational
        }

        return alert
    }
}
