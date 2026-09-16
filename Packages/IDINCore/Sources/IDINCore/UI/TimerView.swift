import SwiftUI

/// Running-task display: pulsing dot, live elapsed timer and the Done button.
public struct TimerView: View {
    /// Where the Done button sits relative to the timer.
    ///
    /// On iPhone the button goes *above* the timer: the bottom edge belongs to the
    /// home-indicator swipe, so a stop button parked there gets hit by accident.
    public enum ActionPlacement: Sendable {
        case aboveTimer
        case belowTimer
    }

    private let task: RunningTask
    private let isSaved: Bool
    private let compact: Bool
    private let actionPlacement: ActionPlacement
    private let onDone: () -> Void

    public init(
        task: RunningTask,
        isSaved: Bool = false,
        compact: Bool = false,
        actionPlacement: ActionPlacement = .belowTimer,
        onDone: @escaping () -> Void
    ) {
        self.task = task
        self.isSaved = isSaved
        self.compact = compact
        self.actionPlacement = actionPlacement
        self.onDone = onDone
    }

    public var body: some View {
        VStack(spacing: compact ? 10 : 22) {
            title

            switch actionPlacement {
            case .aboveTimer:
                action
                elapsed
            case .belowTimer:
                elapsed
                action
            }
        }
    }

    private var title: some View {
        Text(task.text)
            .font(.system(size: compact ? 15 : 26, weight: .semibold))
            .multilineTextAlignment(.center)
            .lineLimit(compact ? 2 : 4)
    }

    private var elapsed: some View {
        VStack(spacing: 6) {
            HStack(spacing: compact ? 7 : 10) {
                PulsingDot(diameter: compact ? 8 : 10)
                Text(task.startTime, style: .timer)
                    .font(.system(size: compact ? 24 : 56, weight: .bold, design: .monospaced))
                    .monospacedDigit()
                    .foregroundStyle(.red)
            }
            Text("Started at \(task.startTime.formatted(date: .omitted, time: .shortened))")
                .font(.system(size: compact ? 10 : 13))
                .foregroundStyle(.tertiary)
        }
    }

    @ViewBuilder
    private var action: some View {
        if isSaved {
            Label("Saved to calendar!", systemImage: "checkmark.circle.fill")
                .font(compact ? .caption : .headline)
                .foregroundStyle(.green)
                .padding(.vertical, compact ? 7 : 16)
                .frame(maxWidth: .infinity)
                .background(.green.opacity(0.12), in: RoundedRectangle(cornerRadius: compact ? 8 : 16))
        } else {
            Button(action: onDone) {
                Label("Done", systemImage: "stop.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, compact ? 2 : 14)
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
            .keyboardShortcut(.return, modifiers: .command)
            .accessibilityLabel("Done — save “\(task.text)” to the calendar")
        }
    }
}

/// Breathing red dot that marks an active session.
struct PulsingDot: View {
    let diameter: CGFloat
    @State private var isPulsing = false

    var body: some View {
        Circle()
            .fill(.red)
            .frame(width: diameter, height: diameter)
            .opacity(isPulsing ? 0.2 : 1.0)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true)) {
                    isPulsing = true
                }
            }
            .accessibilityHidden(true)
    }
}
