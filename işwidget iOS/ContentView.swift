import SwiftUI
import EventKit
import IDINCore

struct ContentView: View {
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
    @AppStorage("iOSTheme") private var themeName = AppTheme.system.rawValue

    private var theme: AppTheme {
        AppTheme(rawValue: themeName) ?? .system
    }

    private let sync = SyncManager.shared
    private let reminders = ReminderPreferences.shared

    var body: some View {
        NavigationStack {
            Group {
                if calendarManager.accessDenied {
                    AccessDeniedView()
                } else if calendarManager.calendars.isEmpty {
                    ProgressView("Loading calendars…")
                } else if let task = sync.runningTask {
                    runningView(task: task, isSaved: false)
                } else if let savedTask {
                    runningView(task: savedTask, isSaved: true)
                } else {
                    idleView
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) { BrandMark() }
                ToolbarItem(placement: .primaryAction) {
                    Button { showSettings = true } label: {
                        Image(systemName: "gearshape")
                    }
                    .disabled(calendarManager.calendars.isEmpty)
                }
            }
        }
        .task {
            await calendarManager.requestAccess()
            adoptDefaultCalendarIfNeeded()
            await refreshReminder(for: sync.runningTask)
        }
        .onChange(of: sync.runningTask) { _, task in
            Task { await refreshReminder(for: task) }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(calendarManager: calendarManager, selectedCalendarID: $selectedCalendarID)
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
            Button("Keep Going") {
                monitor.keepGoing()
                Task { await refreshReminder(for: task) }
            }
            Button("Save & Finish") {
                monitor.dismiss()
                Task { await complete(task) }
            }
        } message: { task in
            Text("You've passed \(task.elapsedText()) on “\(task.text)”.")
        }
        .idinTheme(theme)
    }

    // MARK: Running

    private func runningView(task: RunningTask, isSaved: Bool) -> some View {
        VStack {
            TimelineView(.everyMinute) { context in
                clockStrip(date: context.date)
            }
            Spacer()
            // Done sits above the timer and well clear of the bottom edge, so the
            // home-indicator swipe can't land on it.
            TimerView(task: task, isSaved: isSaved, actionPlacement: .aboveTimer) {
                Task { await complete(task) }
            }
            .padding(.horizontal, 24)
            Spacer()
            Spacer(minLength: 72)
        }
    }

    private func clockStrip(date: Date) -> some View {
        HStack(spacing: 6) {
            Text(date, style: .time).monospacedDigit()
            Text("·").foregroundStyle(.quaternary)
            Text(date, format: .dateTime.weekday(.abbreviated).month(.abbreviated).day())
        }
        .font(.system(size: 14, weight: .light))
        .foregroundStyle(.secondary)
        .padding(.top, 8)
    }

    // MARK: Idle

    private var idleView: some View {
        VStack(spacing: 0) {
            Spacer()

            TimelineView(.everyMinute) { context in
                VStack(spacing: 6) {
                    Text(context.date, style: .time)
                        .font(.system(size: 72, weight: .thin))
                        .monospacedDigit()
                    Text(context.date, format: .dateTime.weekday(.wide).month(.wide).day())
                        .font(.system(size: 16))
                        .foregroundStyle(.secondary)
                }
            }

            Text(Brand.tagline)
                .font(.system(size: 13))
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
                .padding(.top, 20)

            QuoteView(quote: quote)
                .padding(.horizontal, 32)
                .padding(.top, 14)

            Spacer()

            TaskInputView(
                text: $taskText,
                lastTaskText: sync.lastTaskText,
                onStart: start,
                onReuseLast: { _ in start() }
            )
            .padding(20)
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 22))
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
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

    /// Keeps the in-app prompt and the background notification in step with the
    /// running task and the current reminder settings.
    private func refreshReminder(for task: RunningTask?) async {
        monitor.update(for: task)

        guard reminders.isEnabled, let task else {
            ReminderNotifications.cancel()
            return
        }

        await ReminderNotifications.schedule(
            for: task,
            after: monitor.secondsUntilNextPrompt(for: task),
            thresholdText: reminders.thresholdText
        )
    }

    private func adoptDefaultCalendarIfNeeded() {
        let known = calendarManager.calendars.contains { $0.calendarIdentifier == selectedCalendarID }
        if !known, let fallback = calendarManager.defaultCalendarID {
            selectedCalendarID = fallback
        }
    }
}

private struct AccessDeniedView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 52))
                .foregroundStyle(.secondary)
            Text("Calendar access required").font(.headline)
            Text("IDIN writes finished tasks to your calendar. Grant access in Settings › Privacy & Security › Calendars.")
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
}
