import SwiftUI

/// Product naming, used identically on both platforms.
public enum Brand {
    public static let name = "IDIN"
    public static let expansion = "I Do It Now"
    public static let tagline = "Not what you planned. What you did."
    public static let shareMessage = """
        I use IDIN (I Do It Now) to record what I actually worked on instead of what I planned.
        """
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
