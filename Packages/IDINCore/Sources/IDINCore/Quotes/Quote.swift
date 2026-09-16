import Foundation

/// A short line about doing rather than planning, shown on the idle screen.
///
/// Quotes carry both languages instead of living in a String Catalog because each one
/// needs two localized halves (the line *and* the thinker's name — Confucius becomes
/// Konfüçyüs), and keeping them side by side makes the pair reviewable in one place.
public struct Quote: Identifiable, Hashable, Sendable {
    public let id: Int
    public let english: String
    public let turkish: String
    public let authorEnglish: String
    public let authorTurkish: String

    init(
        id: Int,
        english: String,
        turkish: String,
        authorEnglish: String,
        authorTurkish: String
    ) {
        self.id = id
        self.english = english
        self.turkish = turkish
        self.authorEnglish = authorEnglish
        self.authorTurkish = authorTurkish
    }

    public var text: String { Self.prefersTurkish ? turkish : english }
    public var author: String { Self.prefersTurkish ? authorTurkish : authorEnglish }

    /// Reads the device's language list rather than `Locale.current`: the app bundle is
    /// English-only, so `Locale.current` would report English on a Turkish phone.
    static var prefersTurkish: Bool {
        guard let preferred = Locale.preferredLanguages.first else { return false }
        return Locale(identifier: preferred).language.languageCode?.identifier == "tr"
    }
}
