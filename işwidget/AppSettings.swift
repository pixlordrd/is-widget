import Foundation
import SwiftUI
import AppKit

enum AppTheme: String, CaseIterable, Identifiable {
    case indigo = "Indigo"
    case ocean = "Ocean"
    case sunset = "Sunset"

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .indigo: return .indigo
        case .ocean: return Color(hue: 0.58, saturation: 0.75, brightness: 0.88)
        case .sunset: return Color(hue: 0.06, saturation: 0.82, brightness: 0.95)
        }
    }
}

@Observable
class AppSettings {
    static let defaultHeaderColor = Color(.sRGB, red: 0, green: 0, blue: 0, opacity: 0.04)

    var appName: String
    var headerColor: Color
    var themeName: String

    init() {
        appName = UserDefaults.standard.string(forKey: "appName") ?? "IDIN"
        headerColor = AppSettings.loadColor()
        themeName = UserDefaults.standard.string(forKey: "themeName") ?? AppTheme.indigo.rawValue
    }

    var theme: AppTheme {
        AppTheme(rawValue: themeName) ?? .indigo
    }

    func save() {
        UserDefaults.standard.set(appName, forKey: "appName")
        UserDefaults.standard.set(themeName, forKey: "themeName")
        AppSettings.saveColor(headerColor)
    }

    private static func loadColor() -> Color {
        guard let components = UserDefaults.standard.array(forKey: "headerColorRGBA") as? [Double],
              components.count == 4 else {
            return defaultHeaderColor
        }
        return Color(.sRGB, red: components[0], green: components[1], blue: components[2], opacity: components[3])
    }

    static func saveColor(_ color: Color) {
        let nsColor = NSColor(color)
        let target = nsColor.usingColorSpace(.sRGB) ?? nsColor
        let components: [Double] = [
            Double(target.redComponent),
            Double(target.greenComponent),
            Double(target.blueComponent),
            Double(target.alphaComponent)
        ]
        UserDefaults.standard.set(components, forKey: "headerColorRGBA")
    }
}
