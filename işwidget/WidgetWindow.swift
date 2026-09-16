import SwiftUI
import AppKit

/// Turns the app's window into a floating, borderless mini widget that stays
/// visible across Spaces and full-screen apps.
struct WidgetWindowConfigurator: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let probe = WindowProbeView()
        probe.onAttach = { $0.setupAsWidgetWindow() }
        return probe
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}

/// Reports the window as soon as the view joins the hierarchy — no polling or delays.
private final class WindowProbeView: NSView {
    var onAttach: ((NSWindow) -> Void)?

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        if let window { onAttach?(window) }
    }
}

extension NSWindow {
    /// Marks the floating widget window so the app delegate can tell it apart from
    /// the About window.
    static let widgetIdentifier = NSUserInterfaceItemIdentifier("idin-widget")

    func setupAsWidgetWindow() {
        identifier = Self.widgetIdentifier
        level = .floating
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        isMovableByWindowBackground = true
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        styleMask.insert(.fullSizeContentView)
        styleMask.remove(.resizable)
        standardWindowButton(.miniaturizeButton)?.isHidden = true
        standardWindowButton(.zoomButton)?.isHidden = true
    }
}
