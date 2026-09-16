import SwiftUI

/// "What are you working on?" field plus the Start button, shared by both platforms.
public struct TaskInputView: View {
    @Binding private var text: String
    private let lastTaskText: String?
    private let compact: Bool
    private let onStart: () -> Void
    private let onReuseLast: (String) -> Void

    @FocusState private var isFocused: Bool

    public init(
        text: Binding<String>,
        lastTaskText: String? = nil,
        compact: Bool = false,
        onStart: @escaping () -> Void,
        onReuseLast: @escaping (String) -> Void = { _ in }
    ) {
        self._text = text
        self.lastTaskText = lastTaskText
        self.compact = compact
        self.onStart = onStart
        self.onReuseLast = onReuseLast
    }

    private var trimmed: String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    public var body: some View {
        VStack(spacing: compact ? 8 : 12) {
            if let lastTaskText, !lastTaskText.isEmpty {
                Button {
                    text = lastTaskText
                    onReuseLast(lastTaskText)
                } label: {
                    Label("Last: \(lastTaskText)", systemImage: "clock.arrow.circlepath")
                        .font(.system(size: compact ? 10 : 12))
                        .lineLimit(1)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: compact ? .leading : .center)
            }

            TextField("What are you working on?", text: $text, axis: .vertical)
                .textFieldStyle(.plain)
                .font(.system(size: compact ? 14 : 17))
                .multilineTextAlignment(compact ? .leading : .center)
                .lineLimit(2...4)
                .focused($isFocused)
                .onSubmit(start)

            Button(action: start) {
                Label("Start", systemImage: "play.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, compact ? 2 : 12)
            }
            .buttonStyle(.borderedProminent)
            .disabled(trimmed.isEmpty)
            .keyboardShortcut(.return, modifiers: .command)
        }
    }

    private func start() {
        guard !trimmed.isEmpty else { return }
        isFocused = false
        onStart()
    }
}
