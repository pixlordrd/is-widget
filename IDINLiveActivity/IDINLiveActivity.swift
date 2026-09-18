import ActivityKit
import AppIntents
import SwiftUI
import WidgetKit
import IDINCore

/// Live Activity for a running session: Dynamic Island, Lock Screen and the
/// Home Screen banner on devices without an island.
struct IDINLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: IDINActivityAttributes.self) { context in
            LockScreenView(state: context.state)
                .activityBackgroundTint(Color.black.opacity(0.35))
                .activitySystemActionForegroundColor(.primary)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Label {
                        Text(Brand.name)
                    } icon: {
                        Image(systemName: "record.circle")
                    }
                    .font(.caption)
                    .foregroundStyle(.red)
                }

                DynamicIslandExpandedRegion(.trailing) {
                    ElapsedText(startTime: context.state.startTime)
                        .font(.system(.title3, design: .monospaced, weight: .semibold))
                        .foregroundStyle(.red)
                        .frame(maxWidth: 90, alignment: .trailing)
                }

                DynamicIslandExpandedRegion(.center) {
                    Text(context.state.text)
                        .font(.headline)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                }

                DynamicIslandExpandedRegion(.bottom) {
                    FinishButton()
                }
            } compactLeading: {
                Image(systemName: "record.circle")
                    .foregroundStyle(.red)
            } compactTrailing: {
                ElapsedText(startTime: context.state.startTime)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(.red)
                    .frame(maxWidth: 54)
            } minimal: {
                Image(systemName: "record.circle")
                    .foregroundStyle(.red)
            }
            .keylineTint(.red)
            .widgetURL(URL(string: "idin://running"))
        }
    }
}

// MARK: - Pieces

/// Self-updating elapsed time — the system redraws it, so the app never pushes updates.
private struct ElapsedText: View {
    let startTime: Date

    var body: some View {
        Text(timerInterval: startTime...Date.distantFuture, countsDown: false)
            .monospacedDigit()
    }
}

private struct FinishButton: View {
    var body: some View {
        Button(intent: FinishTaskIntent()) {
            Label {
                Text("Save & Finish", bundle: .main)
            } icon: {
                Image(systemName: "stop.fill")
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .tint(.red)
    }
}

private struct LockScreenView: View {
    let state: IDINActivityAttributes.ContentState

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Label {
                    Text(Brand.name)
                } icon: {
                    Image(systemName: "record.circle")
                }
                .font(.caption2)
                .foregroundStyle(.red)

                Text(state.text)
                    .font(.headline)
                    .lineLimit(2)

                ElapsedText(startTime: state.startTime)
                    .font(.system(.title2, design: .monospaced, weight: .bold))
                    .foregroundStyle(.red)
            }

            Spacer(minLength: 0)

            FinishButton()
                .frame(width: 130)
        }
        .padding()
    }
}
