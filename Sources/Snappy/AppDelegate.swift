import AppKit
import Carbon.HIToolbox

/// Point d'entrée unique des actions (menu + raccourcis).
@MainActor
enum AppActions {
    static func perform(_ action: SnapAction) {
        Task {
            switch action {
            case .zone:
                guard let url = await CaptureService.shared.capture(.interactive) else { return }
                CaptureService.shared.copyToPasteboard(url)
                OverlayController.shared.show(url: url)
            case .screen:
                guard let url = await CaptureService.shared.capture(.fullScreen) else { return }
                CaptureService.shared.copyToPasteboard(url)
                OverlayController.shared.show(url: url)
            case .ocr:
                guard let url = await CaptureService.shared.capture(.interactive) else { return }
                defer { try? FileManager.default.removeItem(at: url) }
                guard let text = await OCRService.recognizeText(at: url) else {
                    HUD.show("Aucun texte détecté", symbol: "xmark.circle.fill")
                    return
                }
                let pb = NSPasteboard.general
                pb.clearContents()
                pb.setString(text, forType: .string)
                HUD.show("Texte copié")
            }
        }
    }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Provoque le prompt TCC Screen Recording dès le 1er lancement
        // plutôt qu'un échec silencieux au 1er raccourci.
        if !CGPreflightScreenCaptureAccess() {
            CGRequestScreenCaptureAccess()
        }

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusItem.button?.image = NSImage(
            systemSymbolName: "camera.viewfinder",
            accessibilityDescription: "Snappy"
        )

        let menu = NSMenu()
        for action in SnapAction.allCases {
            let item = NSMenuItem(title: action.title, action: #selector(menuAction(_:)), keyEquivalent: "")
            item.representedObject = action.rawValue
            item.target = self
            menu.addItem(item)
        }
        menu.addItem(.separator())
        menu.addItem(withTitle: "Réglages…", action: #selector(openSettings), keyEquivalent: ",")
        menu.addItem(withTitle: "Quitter Snappy", action: #selector(quit), keyEquivalent: "q")
        menu.items.forEach { $0.target = self }
        statusItem.menu = menu

        ShortcutStore.shared.apply()
    }

    @objc private func menuAction(_ sender: NSMenuItem) {
        guard let raw = sender.representedObject as? String,
              let action = SnapAction(rawValue: raw) else { return }
        AppActions.perform(action)
    }

    @objc private func openSettings() {
        SettingsWindowController.shared.open()
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }
}
