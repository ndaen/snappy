import SwiftUI

/// Overlay post-capture, agencé comme la démo du site : vignette encadrée par
/// les coins de viseur, puis quatre tuiles Copier / Sauver / Annoter / Épingler.
struct OverlayView: View {
    let image: NSImage
    let url: URL
    @State private var pinned = false
    @State private var shown = false
    @AppStorage("overlay.glass") private var translucent = true

    private let contentWidth: CGFloat = 220

    /// Ratio de la capture, hauteur bornée : au-delà, DraggableThumbnail recadre.
    private var thumbHeight: CGFloat {
        let ratio = image.size.height / max(image.size.width, 1)
        return min(150, max(60, contentWidth * ratio))
    }

    var body: some View {
        VStack(spacing: 10) {
            ZStack(alignment: .topTrailing) {
                DraggableThumbnail(image: image, url: url)
                    .frame(width: contentWidth, height: thumbHeight)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(.white.opacity(0.12), lineWidth: 1))
                    .overlay(ViewfinderCorners())

                Button {
                    OverlayController.shared.dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Theme.ink)
                        .frame(width: 20, height: 20)
                        .background(Color.black.opacity(0.55), in: Circle())
                }
                .buttonStyle(.plain)
                .padding(6)
                .help("Fermer")
            }

            HStack(spacing: 6) {
                TileButton("Copier", symbol: "doc.on.doc") {
                    CaptureService.shared.copyToPasteboard(url)
                    try? FileManager.default.removeItem(at: url)
                    OverlayController.shared.dismiss()
                }
                TileButton("Sauver", symbol: "arrow.down.to.line") {
                    _ = CaptureService.shared.saveToDesktop(url)
                    OverlayController.shared.dismiss()
                }
                TileButton("Annoter", symbol: "pencil") {
                    EditorWindowController.shared.open(url: url, image: image)
                    OverlayController.shared.dismiss()
                }
                TileButton("Épingler", symbol: pinned ? "pin.fill" : "pin", active: pinned) {
                    pinned.toggle()
                    OverlayController.shared.setPinned(pinned)
                }
            }
            .frame(width: contentWidth)
        }
        .padding(10)
        .darkGlass(RoundedRectangle(cornerRadius: 16), translucent: translucent)
        .padding(32) // marge pour l'ombre portée dans le panel transparent
        .scaleEffect(shown ? 1 : 0.85, anchor: .bottomTrailing)
        .opacity(shown ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.75)) { shown = true }
        }
    }
}
