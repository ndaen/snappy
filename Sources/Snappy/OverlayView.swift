import SwiftUI

struct OverlayView: View {
    let image: NSImage
    let url: URL
    @State private var pinned = false
    @State private var hovering = false

    private var thumbSize: CGSize {
        let maxW: CGFloat = 260, maxH: CGFloat = 160
        let s = min(maxW / image.size.width, maxH / image.size.height, 1)
        return CGSize(width: image.size.width * s, height: image.size.height * s)
    }

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                DraggableThumbnail(image: image, url: url)
                    .frame(width: thumbSize.width, height: thumbSize.height)
                    .shadow(radius: 3)

                if hovering {
                    HStack(spacing: 10) {
                        centerButton("Copier") {
                            CaptureService.shared.copyToPasteboard(url)
                            try? FileManager.default.removeItem(at: url)
                            OverlayController.shared.dismiss()
                        }
                        centerButton("Sauver") {
                            CaptureService.shared.saveToDesktop(url)
                            OverlayController.shared.dismiss()
                        }
                    }
                }
            }
            .onHover { hovering = $0 }

            HStack(spacing: 14) {
                iconButton("pencil", "Annoter") {
                    EditorWindowController.shared.open(url: url, image: image)
                    OverlayController.shared.dismiss()
                }
                iconButton(pinned ? "pin.fill" : "pin", "Épingler") {
                    pinned = true
                    OverlayController.shared.pin()
                }
                iconButton("xmark", "Fermer") {
                    OverlayController.shared.dismiss()
                }
            }
        }
        .padding(12)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
        .padding(6)
    }

    /// Bouton texte au centre de la vignette (« Copier » = sans sauvegarder sur le bureau).
    private func centerButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .padding(.horizontal, 12).padding(.vertical, 6)
                .background(.regularMaterial, in: Capsule())
        }
        .buttonStyle(.plain)
    }

    private func iconButton(_ symbol: String, _ help: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 15))
                .frame(width: 24, height: 24)
        }
        .buttonStyle(.plain)
        .help(help)
    }
}
