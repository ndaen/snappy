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
        ZStack {
            DraggableThumbnail(image: image, url: url)
                .frame(width: thumbSize.width, height: thumbSize.height)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(radius: 3)

            HStack(spacing: 10) {
                actionButton("Copier") {
                    CaptureService.shared.copyToPasteboard(url)
                    try? FileManager.default.removeItem(at: url)
                    OverlayController.shared.dismiss()
                }
                actionButton("Sauver") {
                    CaptureService.shared.saveToDesktop(url)
                    OverlayController.shared.dismiss()
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 30) // place pour les rangées de coins
        .overlay(alignment: .topLeading) {
            HStack(spacing: 8) {
                cornerButton(pinned ? "pin.fill" : "pin",
                             pinned ? "Dé-épingler" : "Épingler") {
                    pinned.toggle()
                    OverlayController.shared.setPinned(pinned)
                }
                cornerButton("pencil", "Annoter") {
                    EditorWindowController.shared.open(url: url, image: image)
                    OverlayController.shared.dismiss()
                }
            }
            .padding(8)
        }
        .overlay(alignment: .topTrailing) {
            cornerButton("xmark", "Fermer") {
                OverlayController.shared.dismiss()
            }
            .padding(8)
        }
        .modifier(GlassBackground(glass: glass, shape: RoundedRectangle(cornerRadius: 18)))
        .padding(6)
    }

    private func actionButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .padding(.horizontal, 14).padding(.vertical, 7)
                .modifier(GlassBackground(glass: glass, shape: Capsule()))
        }
        .buttonStyle(.plain)
    }

    private func cornerButton(_ symbol: String, _ help: String,
                              action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 12, weight: .bold))
                .frame(width: 24, height: 24)
                .modifier(GlassBackground(glass: glass, shape: Circle()))
        }
        .buttonStyle(.plain)
        .help(help)
    }
}

/// Fond verre : glassEffect natif sur macOS 26+, émulation matériau sinon,
/// matériau opaque si le style Liquid Glass est désactivé dans les Réglages.
struct GlassBackground<S: Shape>: ViewModifier {
    let glass: Bool
    let shape: S

    func body(content: Content) -> some View {
        if glass, #available(macOS 26.0, *) {
            content.glassEffect(.regular, in: shape)
        } else if glass {
            content.background(
                shape.fill(.ultraThinMaterial)
                    .overlay(shape.stroke(
                        LinearGradient(colors: [.white.opacity(0.5), .white.opacity(0.08)],
                                       startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: 1))
                    .shadow(color: .black.opacity(0.25), radius: 12, y: 4))
        } else {
            content.background(shape.fill(.regularMaterial))
        }
    }
}
