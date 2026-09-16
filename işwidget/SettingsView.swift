import SwiftUI
import IDINCore

struct SettingsView: View {
    @Bindable var settings: AppSettings
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openWindow) private var openWindow
    @Bindable private var reminders = ReminderPreferences.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Settings")
                .font(.title3)
                .fontWeight(.semibold)

            Divider()

            Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 10) {
                GridRow {
                    Text("App Name")
                        .foregroundStyle(.secondary)
                        .gridColumnAlignment(.trailing)
                    TextField(Brand.name, text: $settings.appName)
                        .textFieldStyle(.roundedBorder)
                }

                GridRow {
                    Text("Header Color")
                        .foregroundStyle(.secondary)
                        .gridColumnAlignment(.trailing)
                    HStack(spacing: 8) {
                        ColorPicker("", selection: $settings.headerColor, supportsOpacity: true)
                            .labelsHidden()
                            .frame(width: 44)
                        Button("Reset") {
                            settings.headerColor = AppSettings.defaultHeaderColor
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                }

                GridRow {
                    Text("Theme")
                        .foregroundStyle(.secondary)
                        .gridColumnAlignment(.trailing)
                    Picker("", selection: $settings.themeName) {
                        ForEach(AppTheme.allCases) { theme in
                            Label(theme.title, systemImage: theme.symbolName)
                                .tag(theme.rawValue)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.segmented)
                }
            }

            Divider()

            Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 10) {
                GridRow {
                    Text("Reminder")
                        .foregroundStyle(.secondary)
                        .gridColumnAlignment(.trailing)
                    Toggle("Warn me on long sessions", isOn: $reminders.isEnabled)
                }

                if reminders.isEnabled {
                    GridRow {
                        Text("After")
                            .foregroundStyle(.secondary)
                            .gridColumnAlignment(.trailing)
                        Picker("", selection: $reminders.minutes) {
                            ForEach(ReminderPreferences.minuteChoices, id: \.self) { minutes in
                                Text(minutesLabel(minutes)).tag(minutes)
                            }
                        }
                        .labelsHidden()
                        .frame(width: 130)
                    }

                    GridRow {
                        Text("Sound")
                            .foregroundStyle(.secondary)
                            .gridColumnAlignment(.trailing)
                        HStack(spacing: 8) {
                            Picker("", selection: $reminders.sound) {
                                ForEach(AlertSound.allCases) { sound in
                                    Text(sound.title).tag(sound)
                                }
                            }
                            .labelsHidden()
                            .frame(width: 130)
                            .onChange(of: reminders.sound) { _, sound in sound.play() }

                            Button {
                                reminders.sound.play()
                            } label: {
                                Image(systemName: "play.circle")
                            }
                            .buttonStyle(.borderless)
                            .help("Preview sound")
                        }
                    }
                }
            }

            Divider()

            HStack {
                Button {
                    dismiss()
                    openWindow(id: IDINMacApp.aboutWindowID)
                } label: {
                    Label("About \(Brand.name) \(AppVersion.short)", systemImage: "info.circle")
                        .font(.caption)
                }
                .buttonStyle(.link)
                Spacer()
                Button("OK") {
                    settings.save()
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.return)
            }
        }
        .padding()
        .frame(width: 320)
        // Sheets don't inherit the presenter's preferredColorScheme.
        .idinTheme(settings.theme)
    }

    private func minutesLabel(_ minutes: Int) -> String {
        Duration.seconds(minutes * 60)
            .formatted(.units(allowed: [.hours, .minutes], width: .wide))
    }
}
