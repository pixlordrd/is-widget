import SwiftUI
import AppKit
import EventKit
import IDINCore

struct ContentView: View {
    @Bindable var settings: AppSettings

    @State private var calendarManager = CalendarManager()
    @State private var taskText = ""
    /// Kept briefly after Done so the "Saved to calendar!" confirmation can be shown.
    @State private var savedTask: RunningTask?
    @State private var showSettings = false
    @State private var errorMessage: String?
    @State private var monitor = LongRunMonitor()
    /// Chosen once per launch, then re-rolled whenever a new session starts.
    @State private var quote = QuoteLibrary.random()
    @AppStorage("selectedCalendarID") private var selectedCalendarID = ""

    private let sync = SyncManager.shared

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()

            Group {
                if calendarManager.accessDenied {
                    accessDeniedView
                } else if calendarManager.calendars.isEmpty {
                    ProgressView("Loading calendars…").padding(30)
                } else if let task = sync.runningTask {
                    TimerView(task: task, isSaved: false, compact: true) {
                        Task { await complete(task) }
                    }
                    .padding(14)
                } else if let savedTask {
                    TimerView(task: savedTask, isSaved: true, compact: true) {}
                        .padding(14)
                } else {
                    idleView
                }
            }
        }
        .frame(width: 320)
        .background(.regularMaterial)
        .task {
            await calendarManager.requestAccess()
            adoptDefaultCalendarIfNeeded()
            monitor.update(for: sync.runningTask)
        }
        .onChange(of: sync.runningTask) { _, task in
            monitor.update(for: task)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(settings: settings)
        }
        .alert("Could not save", isPresented: .constant(errorMessage != nil)) {
            Button("OK") { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
        .alert(
            "Still on it?",
            isPresented: .constant(monitor.overdueTask != nil),
            presenting: monitor.overdueTask
        ) { task in
            Button("Keep Going") { monitor.keepGoing() }
            Button("Save & Finish") {
                monitor.dismiss()
                Task { await complete(task) }
            }
        } message: { task in
            Text("You've passed \(task.elapsedText()) on “\(task.text)”.")
        }
    }

    // MARK: Header

    private var header: some View {
        HStack(spacing: 6) {
            HStack(spacing: 3) {
                Image(systemName: "clock.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(.tint)
                TimelineView(.everyMinute) { context in
                    Text(context.date, style: .time)
                        .font(.system(size: 11, weight: .medium))
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                }
            }
            Text("·").foregroundStyle(.quaternary)
            Text(settings.appName)
                .font(.system(size: 13, weight: .semibold))
                .lineLimit(1)

            Spacer()

            calendarMenu

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
    private var calendarMenu: some View {
        if !calendarManager.calendars.isEmpty {
            Menu {
                ForEach(calendarManager.calendars, id: \.calendarIdentifier) { calendar in
                    Button {
                        selectedCalendarID = calendar.calendarIdentifier
                    } label: {
                        if calendar.calendarIdentifier == selectedCalendarID {
                            Label(calendar.title, systemImage: "checkmark")
                        } else {
                            Text(calendar.title)
                        }
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    if let current = calendarManager.calendar(id: selectedCalendarID) {
                        Circle()
                            .fill(Color(nsColor: current.color))
                            .frame(width: 8, height: 8)
                        Text(current.title)
                            .font(.system(size: 11))
                            .lineLimit(1)
                    }
                }
            }
            .menuStyle(.borderlessButton)
            .fixedSize()
            .help("Calendar for finished tasks")
        }
    }

    // MARK: Idle

    private var idleView: some View {
        VStack(spacing: 8) {
            Text(Brand.tagline)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.tertiary)
                .frame(maxWidth: .infinity, alignment: .leading)

            QuoteView(quote: quote, compact: true)

            TaskInputView(
                text: $taskText,
                lastTaskText: sync.lastTaskText,
                compact: true,
                onStart: start,
                onReuseLast: { _ in start() }
            )
        }
        .padding(14)
    }

    // MARK: Access denied

    private var accessDeniedView: some View {
        VStack(spacing: 10) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 32))
                .foregroundStyle(.secondary)
            Text("Calendar access required").font(.headline)
            Text("Grant access in System Settings › Privacy & Security › Calendars.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Open System Settings") {
                if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Calendars") {
                    NSWorkspace.shared.open(url)
                }
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
        .padding(20)
    }

    // MARK: Actions

    private func start() {
        sync.start(taskText, calendarID: selectedCalendarID)
        taskText = ""
        quote = QuoteLibrary.random(excluding: quote)
    }

    /// Writes the event first, then clears the shared running state, so a calendar
    /// failure can never lose a session.
    private func complete(_ task: RunningTask) async {
        let calendarID = task.calendarIdentifier.isEmpty ? selectedCalendarID : task.calendarIdentifier
        do {
            try calendarManager.createEvent(
                title: task.text,
                start: task.startTime,
                end: .now,
                calendarID: calendarID
            )
        } catch {
            errorMessage = error.localizedDescription
            return
        }

        sync.finish()
        savedTask = task
        try? await Task.sleep(for: .seconds(2))
        savedTask = nil
        taskText = ""
    }

    private func adoptDefaultCalendarIfNeeded() {
        let known = calendarManager.calendars.contains { $0.calendarIdentifier == selectedCalendarID }
        if !known, let fallback = calendarManager.defaultCalendarID {
            selectedCalendarID = fallback
        }
    }
}
