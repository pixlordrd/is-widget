import SwiftUI
import AppKit
import IDINCore

/// Mac-only presentation preferences, persisted in UserDefaults.
@MainActor
@Observable
final class AppSettings {
    static let defaultHeaderColor = Color(.sRGB, red: 0, green: 0, blue: 0, opacity: 0.04)

    private enum Key {
        static let appName = "appName"
        static let theme = "macTheme"
        static let headerColor = "headerColorRGBA"
    }

    var appName: String
    var headerColor: Color
    var themeName: String

    var theme: AppTheme {
        AppTheme(rawValue: themeName) ?? .system
    }

    init() {
        let defaults = UserDefaults.standard
        appName = defaults.string(forKey: Key.appName) ?? Brand.name
        themeName = defaults.string(forKey: Key.theme) ?? AppTheme.system.rawValue
        headerColor = Self.loadColor(from: defaults)
    }

    func save() {
        let defaults = UserDefaults.standard
        defaults.set(appName.isEmpty ? Brand.name : appName, forKey: Key.appName)
        defaults.set(themeName, forKey: Key.theme)
        defaults.set(Self.components(of: headerColor), forKey: Key.headerColor)
    }

    // MARK: Color storage

    private static func loadColor(from defaults: UserDefaults) -> Color {
        guard let parts = defaults.array(forKey: Key.headerColor) as? [Double], parts.count == 4 else {
            return defaultHeaderColor
        }
        return Color(.sRGB, red: parts[0], green: parts[1], blue: parts[2], opacity: parts[3])
    }

    private static func components(of color: Color) -> [Double] {
        let nsColor = NSColor(color)
        let srgb = nsColor.usingColorSpace(.sRGB) ?? nsColor
        return [
            Double(srgb.redComponent),
            Double(srgb.greenComponent),
            Double(srgb.blueComponent),
            Double(srgb.alphaComponent)
        ]
    }
}
