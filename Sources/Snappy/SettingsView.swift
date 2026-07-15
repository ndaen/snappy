import SwiftUI

struct SettingsView: View {
    @ObservedObject private var store = ShortcutStore.shared

    var body: some View {
        Form {
            Section("Raccourcis") {
                ForEach(SnapAction.allCases) { action in
                    LabeledContent(action.title) {
                        ShortcutRecorderView(action: action)
                    }
                }
            }
            Section {
                Button("Par défaut (remplacer les raccourcis macOS)") {
                    store.adoptSystemShortcuts()
                }
                Text("Désactive les raccourcis capture de macOS (⌘⇧3, ⌘⇧4…) et les assigne à Snappy. Réversible dans Réglages Système → Clavier → Raccourcis → Captures d'écran.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .frame(width: 460)
        .fixedSize(horizontal: false, vertical: true)
    }
}

@MainActor
final class SettingsWindowController {
    static let shared = SettingsWindowController()
    private var window: NSWindow?

    func open() {
        if window == nil {
            let w = NSWindow(contentRect: .zero,
                             styleMask: [.titled, .closable],
                             backing: .buffered, defer: false)
            w.title = "Réglages Snappy"
            w.contentView = NSHostingView(rootView: SettingsView())
            w.isReleasedWhenClosed = false
            w.center()
            window = w
        }
        NSApp.activate(ignoringOtherApps: true)
        window?.makeKeyAndOrderFront(nil)
    }
}
