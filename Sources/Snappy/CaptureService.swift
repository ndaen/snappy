import AppKit
import ApplicationServices

/// Capture via /usr/sbin/screencapture : UI de sélection native gratuite.
/// Toujours vers un fichier temp — c'est l'app qui décide ensuite du routage
/// (presse-papier, bureau, rien), jamais l'option -c.
@MainActor
final class CaptureService {
    static let shared = CaptureService()

    enum Mode {
        case interactive   // crosshair natif ; barre espace → mode fenêtre
        case fullScreen
    }

    private var recordingProcess: Process?
    private var recordingURL: URL?

    var isRecording: Bool { recordingProcess != nil }

    func capture(_ mode: Mode) async -> URL? {
        // Sans permission effective, screencapture re-déclencherait le prompt
        // système à CHAQUE capture. On guide vers les Réglages à la place.
        guard CGPreflightScreenCaptureAccess() else {
            HUD.show("Autorise l'Enregistrement de l'écran, puis relance Snappy",
                     symbol: "exclamationmark.triangle.fill", duration: 4)
            NSWorkspace.shared.open(URL(string:
                "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture")!)
            return nil
        }

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("snappy-\(UUID().uuidString).png")

        var args: [String] = []
        switch mode {
        case .interactive: args = ["-i", "-o"]  // -o : pas d'ombre de fenêtre
        case .fullScreen:  args = []
        }
        args.append(url.path)

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/sbin/screencapture")
        process.arguments = args

        do {
            try process.run()
        } catch {
            NSLog("Snappy: échec lancement screencapture: \(error)")
            return nil
        }
        await withCheckedContinuation { (cont: CheckedContinuation<Void, Never>) in
            process.terminationHandler = { _ in cont.resume() }
        }

        // Sur Esc, l'exit code n'est pas fiable : on teste l'existence du fichier.
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        return url
    }

    /// Démarre l'enregistrement vidéo. Pas de sélection de zone possible :
    /// `screencapture -i -v` est refusé ("video not valid with -i") depuis
    /// macOS 26 — seul le plein écran fonctionne encore en CLI.
    func startVideoRecording() -> Bool {
        guard recordingProcess == nil else { return false }
        guard CGPreflightScreenCaptureAccess() else {
            HUD.show("Autorise l'Enregistrement de l'écran, puis relance Snappy",
                     symbol: "exclamationmark.triangle.fill", duration: 4)
            NSWorkspace.shared.open(URL(string:
                "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture")!)
            return false
        }

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("snappy-\(UUID().uuidString).mov")
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/sbin/screencapture")
        process.arguments = ["-v", url.path]

        do {
            try process.run()
        } catch {
            NSLog("Snappy: échec lancement enregistrement vidéo: \(error)")
            return false
        }
        recordingProcess = process
        recordingURL = url
        return true
    }

    /// Arrête l'enregistrement en cours. SIGINT/SIGTERM tuent le process
    /// sans finaliser le .mov — seule la combinaison ⌃⌘⎋ (le raccourci système
    /// natif d'arrêt) fait écrire le fichier proprement, donc on la simule.
    func stopVideoRecording() async -> URL? {
        guard let process = recordingProcess, let url = recordingURL else { return nil }

        guard AXIsProcessTrusted() else {
            // Littéral plutôt que kAXTrustedCheckOptionPrompt : cette constante CF
            // globale déclenche un diagnostic Swift 6 concurrency-safety.
            let opts = ["AXTrustedCheckOptionPrompt": true] as CFDictionary
            AXIsProcessTrustedWithOptions(opts)
            HUD.show("Autorise Snappy dans Accessibilité pour arrêter l'enregistrement",
                     symbol: "exclamationmark.triangle.fill", duration: 4)
            return nil
        }

        // Déjà terminé (arrêté via ⌃⌘⎋ par l'utilisateur) : on récupère juste le fichier.
        if process.isRunning {
            // Handler posé AVANT la frappe : sinon un process qui se termine
            // très vite ne reprendrait jamais la continuation.
            await withCheckedContinuation { (cont: CheckedContinuation<Void, Never>) in
                process.terminationHandler = { _ in cont.resume() }
                postStopKeystroke()
                // Filet de sécurité : si la frappe n'est pas reçue, on n'attend pas indéfiniment.
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    if process.isRunning { process.terminate() }
                }
            }
        }
        recordingProcess = nil
        recordingURL = nil

        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        return url
    }

    /// Simule ⌃⌘⎋ : seul moyen fiable d'arrêter `screencapture -v` proprement.
    private func postStopKeystroke() {
        let source = CGEventSource(stateID: .hidSystemState)
        let modifiers: CGEventFlags = [.maskCommand, .maskControl]
        let keyDown = CGEvent(keyboardEventSource: source, virtualKey: 53, keyDown: true)  // Escape
        let keyUp = CGEvent(keyboardEventSource: source, virtualKey: 53, keyDown: false)
        keyDown?.flags = modifiers
        keyUp?.flags = modifiers
        keyDown?.post(tap: .cghidEventTap)
        keyUp?.post(tap: .cghidEventTap)
    }

    func copyToPasteboard(_ url: URL) {
        guard let image = NSImage(contentsOf: url) else { return }
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.writeObjects([image])
    }

    /// Destination bureau horodatée, sans espaces (usage terminal).
    func desktopDestination(ext: String = "png") -> URL {
        let desktop = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask)[0]
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HH.mm.ss"
        return desktop.appendingPathComponent("snappy-\(formatter.string(from: Date())).\(ext)")
    }

    /// Déplace le temp vers le bureau. Renvoie l'URL finale.
    @discardableResult
    func saveToDesktop(_ url: URL) -> URL? {
        let dest = desktopDestination(ext: url.pathExtension)
        do {
            try FileManager.default.moveItem(at: url, to: dest)
            return dest
        } catch {
            NSLog("Snappy: échec sauvegarde bureau: \(error)")
            return nil
        }
    }
}
