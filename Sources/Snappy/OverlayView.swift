import SwiftUI

struct OverlayView: View {
    let image: NSImage
    let url: URL
    @State private var pinned = false
    @AppStorage("overlay.glass") private var glass = true

    private var thumbSize: CGSize {
        let maxW: CGFloat = 260, maxH: CGFloat = 160
        let s = min(maxW / image.size.width, maxH / image.size.height, 1)
        return CGSize(width: image.size.width * s, height: image.size.height * s)
    }

    var body: some View {
        VStack(spacing: 8) {
            DraggableThumbnail(image: image, url: url)
                .frame(width: thumbSize.width, height: thumbSize.height)
                .shadow(radius: 3)
                .padding(.top, 14) // place pour la rangée pin/croix

            VStack(spacing: 6) {
                actionButton("Copier", symbol: "doc.on.doc") {
                    CaptureService.shared.copyToPasteboard(url)
                    try? FileManager.default.removeItem(at: url)
                    OverlayController.shared.dismiss()
                }
                actionButton("Sauver", symbol: "square.and.arrow.down") {
                    CaptureService.shared.saveToDesktop(url)
                    OverlayController.shared.dismiss()
                }
                actionButton("Annoter", symbol: "pencil") {
                    EditorWindowController.shared.open(url: url, image: image)
                    OverlayController.shared.dismiss()
                }
            }
        }
        .padding(12)
        .background(background)
        .overlay(alignment: .topTrailing) {
            HStack(spacing: 8) {
                cornerButton(pinned ? "pin.fill" : "pin",
                             pinned ? "Dé-épingler" : "Épingler") {
                    pinned.toggle()
                    OverlayController.shared.setPinned(pinned)
                }
                cornerButton("xmark", "Fermer") {
                    OverlayController.shared.dismiss()
                }
            }
            .padding(10)
        }
        .padding(6)
    }

    /// Fond « Liquid Glass » (réglable) : matériau ultra-fin + liseré lumineux.
    @ViewBuilder private var background: some View {
        let shape = RoundedRectangle(cornerRadius: 18)
        if glass {
            shape.fill(.ultraThinMaterial)
                .overlay(shape.strokeBorder(
                    LinearGradient(colors: [.white.opacity(0.5), .white.opacity(0.08)],
                                   startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: 1))
                .shadow(color: .black.opacity(0.25), radius: 12, y: 4)
        } else {
            shape.fill(.regularMaterial)
        }
    }

    private func actionButton(_ title: String, symbol: String,
                              action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: symbol)
                .font(.system(size: 12, weight: .medium))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .background(glass ? AnyShapeStyle(.white.opacity(0.12))
                                  : AnyShapeStyle(.quaternary),
                            in: Capsule())
        }
        .buttonStyle(.plain)
    }

    private func cornerButton(_ symbol: String, _ help: String,
                              action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 10, weight: .bold))
                .frame(width: 18, height: 18)
                .background(.white.opacity(0.15), in: Circle())
        }
        .buttonStyle(.plain)
        .help(help)
    }
}
