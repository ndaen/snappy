import SwiftUI

struct OverlayView: View {
    let image: NSImage
    let url: URL
    @State private var pinned = false

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

            HStack(spacing: 14) {
                button("doc.on.doc", "Copier (sans sauvegarder)") {
                    CaptureService.shared.copyToPasteboard(url)
                    try? FileManager.default.removeItem(at: url)
                    OverlayController.shared.dismiss()
                }
                button("square.and.arrow.down", "Sauver sur le bureau") {
                    CaptureService.shared.saveToDesktop(url)
                    OverlayController.shared.dismiss()
                }
                button("pencil", "Annoter") {
                    EditorWindowController.shared.open(url: url, image: image)
                    OverlayController.shared.dismiss()
                }
                button(pinned ? "pin.fill" : "pin", "Épingler") {
                    pinned = true
                    OverlayController.shared.pin()
                }
                button("xmark", "Fermer") {
                    OverlayController.shared.dismiss()
                }
            }
        }
        .padding(12)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
        .padding(6)
    }

    private func button(_ symbol: String, _ help: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 15))
                .frame(width: 24, height: 24)
        }
        .buttonStyle(.plain)
        .help(help)
    }
}
