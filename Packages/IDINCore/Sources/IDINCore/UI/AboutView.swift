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

    /// e.g. "Version 2.0 (4)"
    public static var display: String {
        "Version \(short) (\(build))"
    }

    public static var copyright: String? {
        Bundle.main.infoDictionary?["NSHumanReadableCopyright"] as? String
    }
}

/// About screen, shared by both platforms: identity, version, what's new and sharing.
public struct AboutView: View {
    public init() {}

    private let highlights = [
        "Start on one device, finish on another — the running task follows you.",
        "Finished sessions land in the calendar they were started with.",
        "A calendar write that fails no longer loses the session.",
        "Light, dark or system appearance on both platforms."
    ]

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
            Section("New in \(AppVersion.short)") {
                ForEach(highlights, id: \.self) { item in
                    Label(item, systemImage: "checkmark.circle.fill")
                        .labelStyle(.titleAndIcon)
                        .font(.callout)
                }
            }
            Section {
                shareButton
            } footer: {
                if let copyright = AppVersion.copyright {
                    Text(copyright)
                }
            }
        }
        .navigationTitle("About")
        #endif
    }

    private var header: some View {
        VStack(spacing: 10) {
            AppIconView()
            BrandMark(size: 34)
            Text(AppVersion.display)
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
            Text("New in \(AppVersion.short)")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
            ForEach(highlights, id: \.self) { item in
                Label(item, systemImage: "checkmark.circle.fill")
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
            Label("Share \(Brand.name) with a friend", systemImage: "square.and.arrow.up")
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
