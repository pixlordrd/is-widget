import SwiftUI
import EventKit
import IDINCore

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    let calendarManager: CalendarManager
    @Binding var selectedCalendarID: String
    @AppStorage("iOSTheme") private var themeName = AppTheme.system.rawValue
    @Bindable private var reminders = ReminderPreferences.shared

    private var theme: AppTheme {
        AppTheme(rawValue: themeName) ?? .system
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Calendar") {
                    Picker("Save events to", selection: $selectedCalendarID) {
                        ForEach(calendarManager.calendars, id: \.calendarIdentifier) { calendar in
                            Label {
                                Text(calendar.title)
                            } icon: {
                                Circle()
                                    .fill(Color(cgColor: calendar.cgColor))
                                    .frame(width: 10, height: 10)
                            }
                            .tag(calendar.calendarIdentifier)
                        }
                    }
                }

                Section {
                    Toggle("Long session reminder", isOn: $reminders.isEnabled)
                        .onChange(of: reminders.isEnabled) { _, enabled in
                            guard enabled else {
                                ReminderNotifications.cancel()
                                return
                            }
                            Task { await enableReminders() }
                        }

                    if reminders.isEnabled {
                        Picker("Remind me after", selection: $reminders.minutes) {
                            ForEach(ReminderPreferences.minuteChoices, id: \.self) { minutes in
                                Text(minutesLabel(minutes)).tag(minutes)
                            }
                        }
                    }
                } header: {
                    Text("Reminder")
                } footer: {
                    Text("IDIN asks whether to keep going or save the session once it runs longer than this. The alert uses the system notification sound.")
                }

                Section("Appearance") {
                    Picker("Theme", selection: $themeName) {
                        ForEach(AppTheme.allCases) { theme in
                            Label(theme.title, systemImage: theme.symbolName)
                                .tag(theme.rawValue)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }

                Section {
                    ShareLink(item: Brand.shareMessage) {
                        Label("Share \(Brand.name) with a friend", systemImage: "square.and.arrow.up")
                    }
                    NavigationLink {
                        AboutView()
                    } label: {
                        HStack {
                            Label("About \(Brand.name)", systemImage: "info.circle")
                            Spacer()
                            Text(AppVersion.short)
                                .foregroundStyle(.secondary)
                        }
                    }
                } footer: {
                    Text(Brand.tagline)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            // A sheet does not inherit the presenter's preferredColorScheme, so the
            // theme has to be applied here too — otherwise picking Light/Dark looks
            // like it does nothing while Settings is open.
            .idinTheme(theme)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                }
            }
        }
    }

    private func minutesLabel(_ minutes: Int) -> String {
        Duration.seconds(minutes * 60)
            .formatted(.units(allowed: [.hours, .minutes], width: .wide))
    }

    /// Asks for notification permission the first time reminders are switched on, and
    /// arms the reminder for a session that is already running.
    private func enableReminders() async {
        let granted = await ReminderNotifications.requestAuthorization()
        guard granted, let task = SyncManager.shared.runningTask else { return }

        let elapsed = task.elapsed()
        let remaining = max(1, reminders.interval - elapsed)
        await ReminderNotifications.schedule(
            for: task,
            after: remaining,
            thresholdText: reminders.thresholdText
        )
    }
}
