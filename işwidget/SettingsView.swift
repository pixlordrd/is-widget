import SwiftUI

struct SettingsView: View {
    @Bindable var settings: AppSettings
    @Environment(\.dismiss) private var dismiss

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
                    TextField("IDIN", text: $settings.appName)
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
                    HStack(spacing: 12) {
                        ForEach(AppTheme.allCases) { theme in
                            Button {
                                settings.themeName = theme.rawValue
                            } label: {
                                VStack(spacing: 4) {
                                    ZStack {
                                        Circle()
                                            .fill(theme.color)
                                            .frame(width: 24, height: 24)
                                        if settings.themeName == theme.rawValue {
                                            Circle()
                                                .strokeBorder(theme.color, lineWidth: 2)
                                                .frame(width: 30, height: 30)
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 10, weight: .bold))
                                                .foregroundStyle(.white)
                                        }
                                    }
                                    Text(theme.rawValue)
                                        .font(.system(size: 9))
                                        .foregroundStyle(settings.themeName == theme.rawValue ? .primary : .secondary)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }

            Divider()

            HStack {
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
        .frame(width: 290)
    }
}
