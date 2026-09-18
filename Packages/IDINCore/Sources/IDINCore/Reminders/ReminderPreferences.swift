import Foundation
import Observation

/// Settings for the "you've been on this a long time" reminder, shared by both platforms.
@MainActor
@Observable
public final class ReminderPreferences {
    public static let shared = ReminderPreferences()

    /// Thresholds offered in Settings, in minutes.
    public static let minuteChoices = [30, 45, 60, 90, 120]

    public static let defaultMinutes = 60

    private enum Key {
        static let enabled = "reminderEnabled"
        static let minutes = "reminderMinutes"
        static let sound = "reminderSound"
    }

    private let defaults = UserDefaults.standard

    public var isEnabled: Bool {
        didSet { defaults.set(isEnabled, forKey: Key.enabled) }
    }

    public var minutes: Int {
        didSet { defaults.set(minutes, forKey: Key.minutes) }
    }

    public var sound: AlertSound {
        didSet { defaults.set(sound.rawValue, forKey: Key.sound) }
    }

    public var interval: TimeInterval {
        Double(minutes) * 60
    }

    /// e.g. "1 hr" — used in prompts and Settings labels.
    public var thresholdText: String {
        Duration.seconds(interval)
            .formatted(.units(allowed: [.hours, .minutes], width: .abbreviated))
    }

    private init() {
        defaults.register(defaults: [
            Key.enabled: true,
            Key.minutes: Self.defaultMinutes
        ])
        isEnabled = defaults.bool(forKey: Key.enabled)
        sound = defaults.string(forKey: Key.sound).flatMap(AlertSound.init(rawValue:)) ?? .fallback

        // A value stored by a debug build (e.g. 1 minute) must not stick around in a
        // release build, where that choice isn't offered.
        let stored = defaults.integer(forKey: Key.minutes)
        minutes = Self.minuteChoices.contains(stored) ? stored : Self.defaultMinutes
    }
}
