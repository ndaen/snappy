import SwiftUI

struct SettingsView: View {
    @ObservedObject private var store = ShortcutStore.shared
    @AppStorage("overlay.position") private var overlayPosition = OverlayPosition.right.rawValue
    @AppStorage("overlay.glass") private var translucent = true
    @ObservedObject private var updater = UpdaterModel.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            card("Raccourcis") {
                ForEach(SnapAction.allCases) { action in
                    HStack {
                        Text(action.title).foregroundStyle(Theme.ink)
                        Spacer()
                        ShortcutRecorderView(action: action)
                    }
                    if action.id != SnapAction.allCases.last?.id {
                        Rectangle().fill(Theme.line).frame(height: 1)
                    }
                }
            }

            card("Overlay") {
                HStack {
                    Text("Position en bas de l'écran").foregroundStyle(Theme.ink)
                    Spacer()
                    HStack(spacing: 4) {
                        ForEach(OverlayPosition.allCases) { p in
                            Button(p.title) { overlayPosition = p.rawValue }
                                .buttonStyle(ChipButtonStyle(selected: overlayPosition == p.rawValue))
                        }
                    }
                }
                Rectangle().fill(Theme.line).frame(height: 1)
                HStack {
                    Text("Fond translucide").foregroundStyle(Theme.ink)
                    Spacer()
                    Toggle("", isOn: $translucent)
                        .labelsHidden()
                        .toggleStyle(.switch)
                        .tint(Theme.blue)
                }
            }

            card("Mises à jour") {
                HStack {
                    Text("Version installée").foregroundStyle(Theme.ink)
                    Spacer()
                    Text(updater.currentVersion).foregroundStyle(Theme.faint)
                }
                Rectangle().fill(Theme.line).frame(height: 1)
                HStack {
                    Text("Rechercher automatiquement").foregroundStyle(Theme.ink)
                    Spacer()
                    Toggle("", isOn: Binding(get: { updater.automaticallyChecks },
                                             set: { updater.automaticallyChecks = $0 }))
                        .labelsHidden()
                        .toggleStyle(.switch)
                        .tint(Theme.blue)
                }
                Rectangle().fill(Theme.line).frame(height: 1)
                HStack(spacing: 14) {
                    Button(updater.availableVersion.map { "Mettre à jour vers \($0)…" }
                           ?? "Rechercher les mises à jour…") { updater.check() }
                        .buttonStyle(PrimaryButtonStyle())
                    if !updater.isAvailable {
                        Text("Indisponible hors de l'app installée.")
                            .font(.system(size: 12))
                            .foregroundStyle(Theme.faint)
                    }
                }
                .disabled(!updater.isAvailable)
            }

            card("macOS") {
                HStack(alignment: .top, spacing: 14) {
                    Button("Par défaut") { store.adoptSystemShortcuts() }
                        .buttonStyle(PrimaryButtonStyle())
                    Text("Remplace les raccourcis capture de macOS (⌘⇧3, ⌘⇧4…) par ceux de Snappy. Réversible dans Réglages Système › Clavier › Raccourcis › Captures d'écran.")
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.faint)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(.top, 36) // barre de titre transparente
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
        .frame(width: 460)
        .background(Theme.bg)
        .environment(\.colorScheme, .dark)
        .fixedSize(horizontal: false, vertical: true)
    }

    private func card<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Eyebrow(title)
            content()
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.035), in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Theme.line, lineWidth: 1))
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
            w.applySnappyChrome()
            w.contentView = NSHostingView(rootView: SettingsView())
            w.isReleasedWhenClosed = false
            w.center()
            window = w
        }
        NSApp.activate(ignoringOtherApps: true)
        window?.makeKeyAndOrderFront(nil)
    }
}
