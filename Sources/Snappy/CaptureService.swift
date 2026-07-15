import AppKit

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

    func capture(_ mode: Mode) async -> URL? {
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

    func copyToPasteboard(_ url: URL) {
        guard let image = NSImage(contentsOf: url) else { return }
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.writeObjects([image])
    }

    /// Destination bureau horodatée, sans espaces (usage terminal).
    func desktopDestination() -> URL {
        let desktop = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask)[0]
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HH.mm.ss"
        return desktop.appendingPathComponent("snappy-\(formatter.string(from: Date())).png")
    }

    /// Déplace le temp vers le bureau. Renvoie l'URL finale.
    @discardableResult
    func saveToDesktop(_ url: URL) -> URL? {
        let dest = desktopDestination()
        do {
            try FileManager.default.moveItem(at: url, to: dest)
            return dest
        } catch {
            NSLog("Snappy: échec sauvegarde bureau: \(error)")
            return nil
        }
    }
}
