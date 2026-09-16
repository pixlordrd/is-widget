import Foundation
#if canImport(AppKit)
import AppKit
#endif

/// A macOS system alert sound used for the long-running-task reminder.
///
/// iOS has no public API for picking a built-in system sound, so there the reminder
/// arrives as a local notification and uses the standard notification sound.
public enum AlertSound: String, CaseIterable, Identifiable, Codable, Sendable {
    case ping = "Ping"
    case glass = "Glass"
    case hero = "Hero"
    case submarine = "Submarine"
    case sosumi = "Sosumi"
    case tink = "Tink"

    public static let fallback = AlertSound.ping

    public var id: String { rawValue }
    public var title: String { rawValue }

    /// Plays the sound. No-op on platforms without named system sounds.
    public func play() {
        #if canImport(AppKit) && !targetEnvironment(macCatalyst)
        NSSound(named: rawValue)?.play()
        #endif
    }

    /// Whether this platform can play a user-chosen system sound.
    public static var isSelectable: Bool {
        #if canImport(AppKit) && !targetEnvironment(macCatalyst)
        true
        #else
        false
        #endif
    }
}
