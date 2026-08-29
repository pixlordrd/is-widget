import SwiftUI
import EventKit

struct ContentView: View {
    @State private var manager = CalendarManager()
    @State private var sync = SyncManager()
    @State private var taskText = ""
    @State private var isSaved = false
    @State private var showSettings = false
    @AppStorage("iOSTheme") private var themeName: String = AppTheme.indigo.rawValue
    @FocusState private var isTextFocused: Bool

    private var themeColor: Color {
        AppTheme(rawValue: themeName)?.color ?? .indigo
    }

    var body: some View {
        NavigationStack {
            Group {
                if manager.accessDenied {
                    accessDeniedView
                } else if manager.calendars.isEmpty {
                    ProgressView("Loading calendars...")
                } else if let task = sync.runningTask {
                    runningView(task: task)
                } else {
                    idleView
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 1) {
                        Text("IDIN")
                            .font(.system(size: 30, weight: .bold))
                        Text("I Do It Now")
                            .font(.system(size: 10, weight: .light))
                            .foregroundStyle(.secondary)
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button { showSettings = true } label: {
                        Image(systemName: "gearshape")
                    }
                    .disabled(manager.calendars.isEmpty && !manager.accessDenied)
                }
            }
        }
        .task { await manager.requestAccess() }
        .onChange(of: manager.selectedCalendar) { manager.saveSelectedCalendar() }
        .sheet(isPresented: $showSettings) {
            iOSSettingsView(manager: manager, themeName: $themeName)
        }
    }

    // MARK: Running

    private func runningView(task: RunningTaskInfo) -> some View {
        VStack(spacing: 0) {
            // Current time + date strip
            TimelineView(.everyMinute) { context in
                HStack(spacing: 6) {
                    Text(context.date, style: .time)
                        .monospacedDigit()
                    Text("·")
                        .foregroundStyle(.quaternary)
                    Text(context.date, format: .dateTime.weekday(.abbreviated).month(.abbreviated).day())
                }
                .font(.system(size: 14, weight: .light))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 8)
            }

            Spacer()

            // Task name
            Text(task.text)
                .font(.system(size: 26, weight: .semibold))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer().frame(height: 36)

            // Elapsed timer
            VStack(spacing: 6) {
                HStack(spacing: 10) {
                    PulsingDot()
                    Text(task.startTime, style: .timer)
                        .font(.system(size: 56, weight: .bold, design: .monospaced))
                        .foregroundStyle(.red)
                        .monospacedDigit()
                }
                Text("Started at \(task.startTime, style: .time)")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            // Done / Saved
            Group {
                if isSaved {
                    Label("Saved to calendar!", systemImage: "checkmark.circle.fill")
                        .font(.headline)
                        .foregroundStyle(.green)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.green.opacity(0.1), in: RoundedRectangle(cornerRadius: 16))
                } else {
                    Button { finishTask(task: task) } label: {
                        Label("Done", systemImage: "stop.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
    }

    // MARK: Idle

    private var idleView: some View {
        VStack(spacing: 0) {
            Spacer()

            // Clock + date
            TimelineView(.everyMinute) { (context: TimelineViewDefaultContext) in
                VStack(spacing: 6) {
                    Text(context.date, style: .time)
                        .font(.system(size: 72, weight: .thin, design: .default))
                        .monospacedDigit()

                    Text(context.date, format: .dateTime.weekday(.wide).month(.wide).day())
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(.secondary)
                        .kerning(0.3)
                }
            }

            Spacer().frame(height: 20)

            Text("Not what you planned. What you did.")
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)

            if let last = sync.lastTaskText {
                Spacer().frame(height: 14)
                Label(last, systemImage: "clock.arrow.circlepath")
                    .font(.system(size: 12))
                    .foregroundStyle(.quaternary)
                    .lineLimit(1)
                    .padding(.horizontal, 32)
            }

            Spacer()

            // Input card
            VStack(spacing: 0) {
                TextField("What are you working on?", text: $taskText, axis: .vertical)
                    .textFieldStyle(.plain)
                    .font(.system(size: 17, weight: .regular))
                    .multilineTextAlignment(.center)
                    .lineLimit(2...4)
                    .focused($isTextFocused)
                    .frame(minHeight: 64)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 20)

                Divider().padding(.horizontal, 16)

                Button {
                    let calId = manager.selectedCalendar?.calendarIdentifier ?? ""
                    guard !taskText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                    sync.startTask(
                        text: taskText.trimmingCharacters(in: .whitespaces),
                        calendarIdentifier: calId
                    )
                    isTextFocused = false
                } label: {
                    Label("Start", systemImage: "play.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(.borderedProminent)
                .tint(themeColor)
                .disabled(taskText.trimmingCharacters(in: .whitespaces).isEmpty)
                .padding([.horizontal, .bottom], 12)
                .padding(.top, 10)
            }
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 22))
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
    }

    // MARK: Access Denied

    private var accessDeniedView: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 52))
                .foregroundStyle(.secondary)
            Text("Calendar access required").font(.headline)
            Text("Grant access in Settings > Privacy & Security > Calendars.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .buttonStyle(.bordered)
        }
    }

    // MARK: Done

    private func finishTask(task: RunningTaskInfo) {
        let endTime = Date()
        guard let calendar = manager.calendar(for: task.calendarIdentifier),
              !task.text.isEmpty else { return }
        do {
            try manager.createEvent(
                title: task.text,
                startDate: task.startTime,
                endDate: endTime,
                calendar: calendar
            )
            sync.stopTask()
            withAnimation { isSaved = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation { taskText = ""; isSaved = false }
            }
        } catch {
            print("Event save error: \(error)")
        }
    }
}

private struct PulsingDot: View {
    @State private var pulsing = false
    var body: some View {
        Circle()
            .fill(.red)
            .frame(width: 10, height: 10)
            .opacity(pulsing ? 0.2 : 1.0)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true)) {
                    pulsing = true
                }
            }
    }
}
