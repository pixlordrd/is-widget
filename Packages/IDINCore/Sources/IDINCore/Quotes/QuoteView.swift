import SwiftUI

/// The idle-screen quote: one line of encouragement, attributed, kept quiet enough
/// that it never competes with the task field.
public struct QuoteView: View {
    private let quote: Quote
    private let compact: Bool

    public init(quote: Quote, compact: Bool = false) {
        self.quote = quote
        self.compact = compact
    }

    public var body: some View {
        VStack(alignment: compact ? .leading : .center, spacing: compact ? 1 : 4) {
            Text("“\(quote.text)”")
                .font(.system(size: compact ? 10 : 13, weight: .regular))
                .italic()
                .foregroundStyle(.secondary)
                .lineLimit(compact ? 3 : 4)
                .minimumScaleFactor(0.9)

            Text("— \(quote.author)")
                .font(.system(size: compact ? 9 : 11, weight: .medium))
                .foregroundStyle(.tertiary)
        }
        .multilineTextAlignment(compact ? .leading : .center)
        .frame(maxWidth: .infinity, alignment: compact ? .leading : .center)
        .animation(.easeInOut(duration: 0.25), value: quote.id)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(quote.text), \(quote.author)")
    }
}
