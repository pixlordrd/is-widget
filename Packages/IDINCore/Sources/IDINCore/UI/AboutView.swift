import SwiftUI
#if canImport(AppKit)
import AppKit
#endif

/// Version information read from the host app's bundle.
public enum AppVersion {
    public static var short: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
    }

    public static var build: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "—"
    }

    public static var copyright: String? {
        Bundle.main.infoDictionary?["NSHumanReadableCopyright"] as? String
    }
}

/// About screen, shared by both platforms: identity, version, what's new and sharing.
public struct AboutView: View {
    public init() {}

    // Written out one by one so Xcode's string extractor can see each literal.
    private var highlights: [LocalizedStringResource] {
        [
            LocalizedStringResource(
                "Start on one device, finish on another — the running task follows you.",
                bundle: .atURL(Bundle.module.bundleURL)
            ),
            LocalizedStringResource(
                "Finished sessions land in the calendar they were started with.",
                bundle: .atURL(Bundle.module.bundleURL)
            ),
            LocalizedStringResource(
                "A live timer in the Dynamic Island and on the Lock Screen, with a Done button.",
                bundle: .atURL(Bundle.module.bundleURL)
            ),
            LocalizedStringResource(
                "On the Mac, the timer lives in the menu bar and the window tucks away when you minimize it.",
                bundle: .atURL(Bundle.module.bundleURL)
            ),
            LocalizedStringResource(
                "A reminder asks whether to keep going once a session runs long.",
                bundle: .atURL(Bundle.module.bundleURL)
            ),
            LocalizedStringResource(
                "Turkish and English, following your device language.",
                bundle: .atURL(Bundle.module.bundleURL)
            )
        ]
    }

    public var body: some View {
        content
            #if os(macOS)
            .frame(width: 320)
            .padding(22)
            #else
            .padding(.vertical, 8)
            #endif
    }

    @ViewBuilder
    private var content: some View {
        #if os(macOS)
        VStack(spacing: 16) {
            header
            Divider()
            whatsNew
            Divider()
            footer
        }
        #else
        List {
            Section {
                header
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            Section {
                ForEach(highlights, id: \.key) { item in
                    Label {
                        Text(item)
                    } icon: {
                        Image(systemName: "checkmark.circle.fill")
                    }
                    .font(.callout)
                }
            } header: {
                Text("New in \(AppVersion.short)", bundle: Bundle.module)
            }
            Section {
                shareButton
            } footer: {
                if let copyright = AppVersion.copyright {
                    Text(copyright)
                }
            }
        }
        .navigationTitle(Text("About", bundle: Bundle.module))
        #endif
    }

    private var header: some View {
        VStack(spacing: 10) {
            AppIconView()
            BrandMark(size: 34)
            Text("Version \(AppVersion.short) (\(AppVersion.build))", bundle: Bundle.module)
                .font(.callout)
                .monospacedDigit()
                .foregroundStyle(.secondary)
            Text(Brand.tagline)
                .font(.footnote)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
    }

    private var whatsNew: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text("New in \(AppVersion.short)", bundle: Bundle.module)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
            ForEach(highlights, id: \.key) { item in
                Label {
                    Text(item)
                } icon: {
                    Image(systemName: "checkmark.circle.fill")
                }
                .font(.caption)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var footer: some View {
        VStack(spacing: 10) {
            shareButton
            if let copyright = AppVersion.copyright {
                Text(copyright)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
    }

    private var shareButton: some View {
        ShareLink(item: Brand.shareMessage) {
            Label {
                Text("Share \(Brand.name) with a friend", bundle: Bundle.module)
            } icon: {
                Image(systemName: "square.and.arrow.up")
            }
        }
    }
}

/// The app's own icon, loaded from the host bundle.
private struct AppIconView: View {
    private let side: CGFloat = 64

    var body: some View {
        #if canImport(AppKit) && !targetEnvironment(macCatalyst)
        Image(nsImage: NSApplication.shared.applicationIconImage)
            .resizable()
            .frame(width: side, height: side)
        #else
        // Asset-catalog app icons cannot be loaded by name on iOS, so use a glyph.
        Image(systemName: "clock.badge.checkmark.fill")
            .font(.system(size: side * 0.7))
            .foregroundStyle(.tint)
        #endif
    }
}
