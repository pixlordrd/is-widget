import SwiftUI
import AppKit
import EventKit

struct ContentView: View {
    @State private var manager = CalendarManager()
    @State private var sync = SyncManager()
    @State private var settings = AppSettings()
    @State private var taskText = ""
    @State private var startTime = Date()
    @State private var isRunning = false
    @State private var isSaved = false
    @State private var showSettings = false
    @FocusState private var isTextFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            headerBar
            Divider()
            if manager.accessDenied {
                accessDeniedView
            } else if manager.calendars.isEmpty {
                loadingView
            } else {
                mainForm
            }
        }
        .frame(width: 320)
        .background(.regularMaterial)
        .task { await manager.requestAccess() }
        .onChange(of: manager.selectedCalendar) { manager.saveSelectedCalendar() }
        .onChange(of: sync.runningTask) { _, newTask in
            if let task = newTask, !isRunning {
                taskText = task.text
                startTime = task.startTime
                withAnimation(.spring(duration: 0.3)) { isRunning = true }
            } else if newTask == nil, isRunning {
                withAnimation(.spring(duration: 0.3)) {
                    isRunning = false
                    taskText = ""
                    startTime = Date()
                }
            }
        }
        .onAppear { setupWindow() }
        .sheet(isPresented: $showSettings) { SettingsView(settings: settings) }
    }

    // MARK: Header

    private var headerBar: some View {
        HStack(spacing: 6) {
            HStack(spacing: 3) {
                Image(systemName: "clock.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(.tint)
                Text(Date(), style: .time)
                    .font(.system(size: 11, weight: .medium))
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }
            Text("·").foregroundStyle(.quaternary)
            Text(settings.appName)
                .font(.system(size: 13, weight: .semibold))
                .lineLimit(1)
            Spacer()
            calendarPicker
            Button { showSettings = true } label: {
                Image(systemName: "gearshape")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .help("Settings")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .background(settings.headerColor)
    }

    @ViewBuilder
    private var calendarPicker: some View {
        if !manager.calendars.isEmpty {
            HStack(spacing: 4) {
                if let cal = manager.selectedCalendar {
                    Circle().fill(Color(nsColor: cal.color)).frame(width: 8, height: 8)
                }
                Picker("", selection: $manager.selectedCalendar) {
                    ForEach(manager.calendars, id: \.calendarIdentifier) { cal in
                        Text(cal.title).tag(Optional(cal))
                    }
                }
                .labelsHidden()
                .frame(maxWidth: 120)
            }
        }
    }

    // MARK: States

    private var loadingView: some View {
        ProgressView("Loading calendars...").padding(30)
    }

    private var accessDeniedView: some View {
        VStack(spacing: 10) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 32)).foregroundStyle(.secondary)
            Text("Calendar access required").font(.headline)
            Text("Grant access in System Settings > Privacy > Calendars.")
                .font(.caption).foregroundStyle(.secondary).multilineTextAlignment(.center)
            Button("Open System Settings") {
                if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Calendars") {
                    NSWorkspace.shared.open(url)
                }
            }
            .buttonStyle(.bordered).controlSize(.small)
        }
        .padding(20)
    }

    // MARK: Main Form

    private var mainForm: some View {
        VStack(spacing: 10) {
            if !isRunning {
                VStack(spacing: 2) {
                    Text("Not what you planned. What you did.")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.tertiary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    if let last = sync.lastTaskText {
                        HStack(spacing: 4) {
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.system(size: 9))
                            Text("Last: \(last)")
                                .lineLimit(1)
                        }
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }

            TextField("What are you working on?", text: $taskText, axis: .vertical)
                .textFieldStyle(.plain)
                .font(.system(size: 14))
                .lineLimit(2...5)
                .focused($isTextFocused)
                .disabled(isRunning)

            Divider()

            if isRunning {
                timerControls
            } else {
                startButton
            }
        }
        .padding(14)
    }

    private var startButton: some View {
        Button {
            startTime = Date()
            sync.startTask(
                text: taskText.trimmingCharacters(in: .whitespaces),
                calendarIdentifier: manager.selectedCalendar?.calendarIdentifier ?? ""
            )
            withAnimation(.spring(duration: 0.3)) { isRunning = true }
            isTextFocused = false
        } label: {
            Label("Start", systemImage: "play.fill")
                .frame(maxWidth: .infinity)
                .padding(.vertical, 2)
        }
        .buttonStyle(.borderedProminent)
        .tint(settings.theme.color)
        .disabled(taskText.trimmingCharacters(in: .whitespaces).isEmpty)
        .keyboardShortcut(.return, modifiers: .command)
    }

    private var timerControls: some View {
        VStack(spacing: 10) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("STARTED")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(.secondary)
                    Text(startTime, style: .time)
                        .font(.system(size: 13, weight: .semibold))
                        .monospacedDigit()
                }
                Spacer()
                HStack(spacing: 7) {
                    PulsingDot()
                    Text(startTime, style: .timer)
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .foregroundStyle(.red)
                }
            }

            if isSaved {
                Label("Saved to calendar!", systemImage: "checkmark.circle.fill")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 7)
                    .background(.green.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))
                    .foregroundStyle(.green)
            } else {
                Button { finishTask() } label: {
                    Label("Done", systemImage: "stop.fill")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 2)
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .keyboardShortcut(.return, modifiers: .command)
            }
        }
    }

    // MARK: Actions

    private func finishTask() {
        let endTime = Date()
        guard let calendar = manager.selectedCalendar ?? manager.calendars.first,
              !taskText.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        do {
            try manager.createEvent(
                title: taskText.trimmingCharacters(in: .whitespaces),
                startDate: startTime,
                endDate: endTime,
                calendar: calendar
            )
            sync.stopTask()
            withAnimation { isSaved = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.spring(duration: 0.4)) {
                    taskText = ""
                    startTime = Date()
                    isRunning = false
                    isSaved = false
                }
            }
        } catch {
            print("Event save error: \(error)")
        }
    }

    private func setupWindow() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            guard let window = NSApplication.shared.windows.first else { return }
            window.level = .floating
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
            window.isMovableByWindowBackground = true
            window.titlebarAppearsTransparent = true
            window.titleVisibility = .hidden
            window.styleMask.insert(.fullSizeContentView)
        }
    }
}

private struct PulsingDot: View {
    @State private var pulsing = false
    var body: some View {
        Circle()
            .fill(.red)
            .frame(width: 8, height: 8)
            .opacity(pulsing ? 0.2 : 1.0)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true)) {
                    pulsing = true
                }
            }
    }
}
