import SwiftUI

/// Product naming, used identically on both platforms.
///
/// Strings that reach the screen resolve against `Bundle.module`, so they can be
/// translated in the package's own String Catalog.
public enum Brand {
    /// Not localized — the product name is the same in every language.
    public static let name = "IDIN"

    public static var expansion: LocalizedStringResource {
        LocalizedStringResource("I Do It Now", bundle: .atURL(Bundle.module.bundleURL))
    }

    public static var tagline: LocalizedStringResource {
        LocalizedStringResource("Not what you planned. What you did.", bundle: .atURL(Bundle.module.bundleURL))
    }

    /// Plain text for the share sheet, resolved in the current language.
    public static var shareMessage: String {
        String(
            localized: "I use IDIN (I Do It Now) to record what I actually worked on instead of what I planned.",
            bundle: Bundle.module
        )
    }
}

/// Stacked wordmark: IDIN over "I Do It Now".
public struct BrandMark: View {
    private let size: CGFloat

    public init(size: CGFloat = 30) {
        self.size = size
    }

    public var body: some View {
        VStack(spacing: 1) {
            Text(Brand.name)
                .font(.system(size: size, weight: .bold))
            Text(Brand.expansion)
                .font(.system(size: size / 3, weight: .light))
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(Brand.name), \(Brand.expansion)")
    }
}
