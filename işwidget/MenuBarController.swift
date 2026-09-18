import AppKit
import Observation
import IDINCore

/// Menu bar presence for the Mac app.
///
/// The status item is always there, so the widget window can be parked away and
/// brought back without a Dock round-trip. While a session runs it also shows the
/// elapsed time, which is the one thing worth glancing at with the window hidden.
@MainActor
final class MenuBarController: NSObject {
    /// Invoked when the person clicks the status item.
    var onToggleWindow: (() -> Void)?

    private var statusItem: NSStatusItem?
    private var ticker: Task<Void, Never>?

    func install() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        item.button?.imagePosition = .imageLeading
        item.button?.target = self
        item.button?.action = #selector(handleClick)
        item.button?.sendAction(on: [.leftMouseUp, .rightMouseUp])
        statusItem = item

        observeRunningTask()
        refresh()
    }

    // MARK: Clicks

    @objc private func handleClick() {
        if NSApp.currentEvent?.type == .rightMouseUp {
            presentMenu()
        } else {
            onToggleWindow?()
        }
    }

    private func presentMenu() {
        guard let statusItem else { return }

        let menu = NSMenu()
        let show = menu.addItem(
            withTitle: String(localized: "Show \(Brand.name)"),
            action: #selector(showWindow),
            keyEquivalent: ""
        )
        show.target = self

        menu.addItem(.separator())

        let quit = menu.addItem(
            withTitle: String(localized: "Quit \(Brand.name)"),
            action: #selector(quit),
            keyEquivalent: "q"
        )
        quit.target = self

        // Attaching the menu only for this click keeps left-click free for toggling.
        statusItem.menu = menu
        statusItem.button?.performClick(nil)
        statusItem.menu = nil
    }

    @objc private func showWindow() {
        onToggleWindow?()
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }

    // MARK: Contents

    private func refresh() {
        guard let button = statusItem?.button else { return }

        if let task = SyncManager.shared.runningTask {
            button.image = NSImage(systemSymbolName: "record.circle", accessibilityDescription: Brand.name)
            button.title = " \(Self.compactElapsed(since: task.startTime))"
            button.toolTip = task.text
            startTicking()
        } else {
            button.image = NSImage(systemSymbolName: "clock", accessibilityDescription: Brand.name)
            button.title = ""
            button.toolTip = Brand.name
            stopTicking()
        }
    }

    /// Short enough for the menu bar: "4dk", "1sa 12dk".
    private static func compactElapsed(since start: Date) -> String {
        let seconds = max(0, Date().timeIntervalSince(start))
        return Duration.seconds(seconds)
            .formatted(.units(allowed: [.hours, .minutes], width: .narrow, maximumUnitCount: 2))
    }

    /// Half-minute cadence: the menu bar only shows minutes, so a per-second timer
    /// would burn wakeups for nothing.
    private func startTicking() {
        guard ticker == nil else { return }
        ticker = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(30))
                guard !Task.isCancelled else { return }
                self?.refresh()
            }
        }
    }

    private func stopTicking() {
        ticker?.cancel()
        ticker = nil
    }

    /// Re-arms itself after every change, which is how Observation reports a stream
    /// of updates rather than just the first one.
    private func observeRunningTask() {
        withObservationTracking {
            _ = SyncManager.shared.runningTask
        } onChange: { [weak self] in
            Task { @MainActor in
                self?.refresh()
                self?.observeRunningTask()
            }
        }
    }
}
