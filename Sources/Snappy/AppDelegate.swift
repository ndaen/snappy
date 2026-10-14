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
            case .video:
                if CaptureService.shared.isRecording {
                    guard let url = await CaptureService.shared.stopVideoRecording() else { return }
                    guard let saved = CaptureService.shared.saveToDesktop(url) else { return }
                    NSWorkspace.shared.activateFileViewerSelecting([saved])
                    HUD.show("Vidéo enregistrée sur le bureau")
                } else if CaptureService.shared.startVideoRecording() {
                    HUD.show("Enregistrement en cours — relance le raccourci pour arrêter",
                             symbol: "record.circle", duration: 4)
                }
            }
        }
    }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    private var statusItem: NSStatusItem!
    private var videoMenuItem: NSMenuItem?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Provoque le prompt TCC Screen Recording au 1er lancement, UNE SEULE fois :
        // la permission ne prend effet qu'au relancement de l'app, donc redemander
        // à chaque lancement/capture crée une boucle de prompts.
        if !CGPreflightScreenCaptureAccess(),
           !UserDefaults.standard.bool(forKey: "didRequestScreenAccess") {
            UserDefaults.standard.set(true, forKey: "didRequestScreenAccess")
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
            if action == .video { videoMenuItem = item }
        }
        menu.addItem(.separator())
        menu.addItem(withTitle: "Réglages…", action: #selector(openSettings), keyEquivalent: ",")
        menu.addItem(withTitle: "Quitter Snappy", action: #selector(quit), keyEquivalent: "q")
        menu.items.forEach { $0.target = self }
        menu.delegate = self
        statusItem.menu = menu

        ShortcutStore.shared.apply()
    }

    func menuWillOpen(_ menu: NSMenu) {
        videoMenuItem?.title = CaptureService.shared.isRecording
            ? "Arrêter l'enregistrement" : SnapAction.video.title
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
