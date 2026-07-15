import AppKit
import SwiftUI

/// Overlay flottant post-capture : NSPanel non-activating en bas à droite,
/// au-dessus de tout, sur tous les Spaces. Un seul overlay à la fois —
/// une nouvelle capture remplace la précédente.
@MainActor
final class OverlayController {
    static let shared = OverlayController()

    private var panel: NSPanel?
    private var dismissTask: Task<Void, Never>?
    private(set) var currentURL: URL?

    func show(url: URL) {
        guard let image = NSImage(contentsOf: url) else { return }
        currentURL = url

        let panel = self.panel ?? makePanel()
        self.panel = panel

        let view = OverlayView(image: image, url: url)
        panel.contentView = NSHostingView(rootView: view)

        let size = panel.contentView!.fittingSize
        panel.setContentSize(size)
        if let screen = NSScreen.main {
            let f = screen.visibleFrame
            panel.setFrameOrigin(NSPoint(x: f.maxX - size.width - 20, y: f.minY + 20))
        }
        panel.orderFrontRegardless()
        scheduleDismiss()
    }

    func pin() {
        dismissTask?.cancel()
        dismissTask = nil
    }

    func dismiss() {
        dismissTask?.cancel()
        dismissTask = nil
        panel?.orderOut(nil)
        currentURL = nil
    }

    private func scheduleDismiss() {
        dismissTask?.cancel()
        dismissTask = Task {
            try? await Task.sleep(for: .seconds(6))
            if !Task.isCancelled { self.dismiss() }
        }
    }

    private func makePanel() -> NSPanel {
        let panel = NSPanel(contentRect: .zero,
                            styleMask: [.nonactivatingPanel, .borderless],
                            backing: .buffered, defer: false)
        panel.level = .screenSaver
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        panel.isFloatingPanel = true
        panel.hidesOnDeactivate = false
        panel.becomesKeyOnlyIfNeeded = true
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = true
        return panel
    }
}

/// Vignette draggable en AppKit (onDrag SwiftUI est peu fiable depuis un
/// panel non-activating) : drag = dépose le fichier PNG dans Finder/apps.
struct DraggableThumbnail: NSViewRepresentable {
    let image: NSImage
    let url: URL

    func makeNSView(context: Context) -> DragView {
        let v = DragView()
        v.image = image
        v.fileURL = url
        return v
    }

    func updateNSView(_ v: DragView, context: Context) {
        v.image = image
        v.fileURL = url
    }

    final class DragView: NSView, NSDraggingSource {
        var image: NSImage? { didSet { needsDisplay = true } }
        var fileURL: URL?

        override func draw(_ dirtyRect: NSRect) {
            guard let image else { return }
            let path = NSBezierPath(roundedRect: bounds, xRadius: 8, yRadius: 8)
            path.addClip()
            image.draw(in: bounds, from: .zero, operation: .sourceOver, fraction: 1)
        }

        override func mouseDragged(with event: NSEvent) {
            guard let fileURL, let image else { return }
            let item = NSDraggingItem(pasteboardWriter: fileURL as NSURL)
            item.setDraggingFrame(bounds, contents: image)
            beginDraggingSession(with: [item], event: event, source: self)
        }

        func draggingSession(_ session: NSDraggingSession,
                             sourceOperationMaskFor context: NSDraggingContext) -> NSDragOperation {
            .copy
        }
    }
}
