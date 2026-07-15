import AppKit
import SwiftUI
import Vision

enum OCRService {
    /// Reconnaît le texte de l'image et le renvoie, lignes jointes par \n.
    static func recognizeText(at url: URL) async -> String? {
        await Task.detached {
            let request = VNRecognizeTextRequest()
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true
            request.recognitionLanguages = ["fr-FR", "en-US"]
            let handler = VNImageRequestHandler(url: url)
            guard (try? handler.perform([request])) != nil,
                  let observations = request.results, !observations.isEmpty else { return nil }
            return observations
                .compactMap { $0.topCandidates(1).first?.string }
                .joined(separator: "\n")
        }.value
    }
}

/// Petit HUD de confirmation (« Texte copié ») qui s'efface tout seul.
@MainActor
enum HUD {
    private static var panel: NSPanel?
    private static var task: Task<Void, Never>?

    static func show(_ message: String, symbol: String = "checkmark.circle.fill",
                     duration: Double = 1.5) {
        panel?.orderOut(nil)
        let view = NSHostingView(rootView:
            Label(message, systemImage: symbol)
                .font(.system(size: 14, weight: .medium))
                .padding(.horizontal, 16).padding(.vertical, 10)
                .background(.regularMaterial, in: Capsule())
                .padding(6)
        )
        let p = NSPanel(contentRect: .zero,
                        styleMask: [.nonactivatingPanel, .borderless],
                        backing: .buffered, defer: false)
        p.level = .screenSaver
        p.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        p.backgroundColor = .clear
        p.isOpaque = false
        p.hasShadow = false
        p.contentView = view
        let size = view.fittingSize
        p.setContentSize(size)
        if let f = NSScreen.main?.visibleFrame {
            p.setFrameOrigin(NSPoint(x: f.midX - size.width / 2, y: f.minY + 60))
        }
        p.orderFrontRegardless()
        panel = p

        task?.cancel()
        task = Task {
            try? await Task.sleep(for: .seconds(duration))
            if !Task.isCancelled { panel?.orderOut(nil); panel = nil }
        }
    }
}
