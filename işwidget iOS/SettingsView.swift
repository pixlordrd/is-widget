import SwiftUI
import EventKit

enum AppTheme: String, CaseIterable, Identifiable {
    case indigo = "Indigo"
    case ocean = "Ocean"
    case sunset = "Sunset"

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .indigo: return .indigo
        case .ocean: return Color(hue: 0.58, saturation: 0.75, brightness: 0.88)
        case .sunset: return Color(hue: 0.06, saturation: 0.82, brightness: 0.95)
        }
    }
}

struct iOSSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    let manager: CalendarManager
    @Binding var themeName: String
    @State private var showShareSheet = false

    var body: some View {
        NavigationStack {
            Form {
                calendarSection
                themeSection
                shareSection
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet()
        }
    }

    private var calendarSection: some View {
        Section("Calendar") {
            let calendars: [EKCalendar] = manager.calendars
            ForEach(calendars, id: \.calendarIdentifier) { cal in
                calendarRow(cal)
            }
        }
    }

    private func calendarRow(_ cal: EKCalendar) -> some View {
        Button {
            manager.selectedCalendar = cal
            manager.saveSelectedCalendar()
        } label: {
            HStack {
                Circle()
                    .fill(Color(cgColor: cal.cgColor))
                    .frame(width: 10, height: 10)
                Text(cal.title)
                    .foregroundStyle(.primary)
                Spacer()
                if manager.selectedCalendar?.calendarIdentifier == cal.calendarIdentifier {
                    Image(systemName: "checkmark")
                        .fontWeight(.semibold)
                        .foregroundStyle(.accentColor)
                }
            }
        }
    }

    private var themeSection: some View {
        Section("Theme") {
            HStack(spacing: 0) {
                ForEach(AppTheme.allCases) { theme in
                    ThemeSwatch(theme: theme, isSelected: themeName == theme.rawValue) {
                        themeName = theme.rawValue
                    }
                    if theme.rawValue != AppTheme.allCases.last?.rawValue {
                        Spacer()
                    }
                }
            }
            .padding(.vertical, 6)
        }
    }

    private var shareSection: some View {
        Section {
            Button {
                showShareSheet = true
            } label: {
                Label("Share IDIN with a friend", systemImage: "square.and.arrow.up")
            }
        }
    }
}

private struct ThemeSwatch: View {
    let theme: AppTheme
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        VStack(spacing: 7) {
            ZStack {
                Circle()
                    .fill(theme.color)
                    .frame(width: 44, height: 44)
                    .shadow(color: theme.color.opacity(0.4), radius: isSelected ? 6 : 0)
                if isSelected {
                    Circle()
                        .strokeBorder(theme.color, lineWidth: 2.5)
                        .frame(width: 54, height: 54)
                    Image(systemName: "checkmark")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
            Text(theme.rawValue)
                .font(.system(size: 12, weight: isSelected ? .semibold : .regular))
                .foregroundStyle(isSelected ? .primary : .secondary)
        }
        .onTapGesture(perform: onTap)
    }
}

private struct ShareSheet: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(
            activityItems: ["I use IDIN (I Do It Now) to track what I actually work on instead of what I planned. Simple, honest productivity."],
            applicationActivities: nil
        )
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
