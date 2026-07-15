import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

enum EditorTool: String, CaseIterable, Identifiable {
    case arrow, rect, highlight, blur, text
    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .arrow: "arrow.up.right"
        case .rect: "rectangle"
        case .highlight: "highlighter"
        case .blur: "circle.dotted"
        case .text: "textformat"
        }
    }

    var help: String {
        switch self {
        case .arrow: "Flèche"
        case .rect: "Rectangle"
        case .highlight: "Surlignage"
        case .blur: "Flou (pixellisation)"
        case .text: "Texte"
        }
    }
}

/// Toutes les coordonnées sont en points d'affichage (la fenêtre n'est pas
/// redimensionnable) ; l'export repasse à la taille pixel via ImageRenderer.scale.
struct AnnotationShape: Identifiable {
    let id = UUID()
    var tool: EditorTool
    var start: CGPoint
    var end: CGPoint
    var text: String = ""
    var blurPatch: NSImage?   // patch pixellisé, calculé à la fin du drag

    var rect: CGRect {
        CGRect(x: min(start.x, end.x), y: min(start.y, end.y),
               width: abs(end.x - start.x), height: abs(end.y - start.y))
    }
}

struct EditorView: View {
    let image: NSImage
    let cgImage: CGImage
    let displaySize: CGSize

    @State private var tool: EditorTool = .arrow
    @State private var shapes: [AnnotationShape] = []
    @State private var draft: AnnotationShape?
    @FocusState private var focusedText: UUID?

    init(image: NSImage, cgImage: CGImage) {
        self.image = image
        self.cgImage = cgImage
        let maxSize = CGSize(width: 1100, height: 700)
        let s = min(maxSize.width / image.size.width, maxSize.height / image.size.height, 1)
        self.displaySize = CGSize(width: image.size.width * s, height: image.size.height * s)
    }

    var body: some View {
        VStack(spacing: 0) {
            toolbar
            canvas
                .frame(width: displaySize.width, height: displaySize.height)
        }
    }

    private var toolbar: some View {
        HStack {
            Picker("", selection: $tool) {
                ForEach(EditorTool.allCases) { t in
                    Image(systemName: t.symbol).help(t.help).tag(t)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 220)

            Spacer()

            Button("Annuler", systemImage: "arrow.uturn.backward") {
                if !shapes.isEmpty { shapes.removeLast() }
            }
            .disabled(shapes.isEmpty)

            Button("Copier", systemImage: "doc.on.doc") {
                if let img = renderResult() {
                    let pb = NSPasteboard.general
                    pb.clearContents()
                    pb.writeObjects([img])
                    HUD.show("Copié")
                }
            }
            Button("Sauver", systemImage: "square.and.arrow.down") {
                if let img = renderResult() { saveToDesktop(img) }
            }
        }
        .labelStyle(.titleAndIcon)
        .padding(10)
    }

    private var canvas: some View {
        annotatedContent(interactive: true)
            .gesture(dragGesture)
            .onTapGesture { location in
                guard tool == .text else { return }
                let shape = AnnotationShape(tool: .text, start: location, end: location)
                shapes.append(shape)
                focusedText = shape.id
            }
    }

    /// Contenu partagé affichage/export : image + Canvas + champs texte.
    private func annotatedContent(interactive: Bool) -> some View {
        ZStack(alignment: .topLeading) {
            Image(nsImage: image)
                .resizable()
                .frame(width: displaySize.width, height: displaySize.height)

            Canvas { ctx, _ in
                for shape in shapes + (draft.map { [$0] } ?? []) where shape.tool != .text {
                    draw(shape, in: &ctx)
                }
            }
            .frame(width: displaySize.width, height: displaySize.height)
            .allowsHitTesting(false)

            ForEach($shapes) { $shape in
                if shape.tool == .text {
                    TextField("Texte", text: $shape.text)
                        .textFieldStyle(.plain)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.red)
                        .focused($focusedText, equals: shape.id)
                        .fixedSize()
                        .position(shape.start)
                        .allowsHitTesting(interactive)
                }
            }
        }
        .clipped()
    }

    private func draw(_ shape: AnnotationShape, in ctx: inout GraphicsContext) {
        switch shape.tool {
        case .arrow:
            var path = Path()
            path.move(to: shape.start)
            path.addLine(to: shape.end)
            // pointe de flèche
            let angle = atan2(shape.end.y - shape.start.y, shape.end.x - shape.start.x)
            let len: CGFloat = 14
            for side in [angle + .pi * 0.85, angle - .pi * 0.85] {
                path.move(to: shape.end)
                path.addLine(to: CGPoint(x: shape.end.x + len * cos(side),
                                         y: shape.end.y + len * sin(side)))
            }
            ctx.stroke(path, with: .color(.red), style: StrokeStyle(lineWidth: 3, lineCap: .round))
        case .rect:
            ctx.stroke(Path(roundedRect: shape.rect, cornerRadius: 2),
                       with: .color(.red), lineWidth: 3)
        case .highlight:
            ctx.fill(Path(shape.rect), with: .color(.yellow.opacity(0.35)))
        case .blur:
            if let patch = shape.blurPatch {
                ctx.draw(Image(nsImage: patch), in: shape.rect)
            } else {
                ctx.stroke(Path(shape.rect), with: .color(.gray),
                           style: StrokeStyle(lineWidth: 1, dash: [4]))
            }
        case .text:
            break
        }
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 3)
            .onChanged { v in
                guard tool != .text else { return }
                if draft == nil {
                    draft = AnnotationShape(tool: tool, start: v.startLocation, end: v.location)
                } else {
                    draft?.end = v.location
                }
            }
            .onEnded { v in
                guard var shape = draft else { return }
                shape.end = v.location
                if shape.tool == .blur {
                    shape.blurPatch = pixellatePatch(for: shape.rect)
                }
                shapes.append(shape)
                draft = nil
            }
    }

    /// Crop du CGImage source sur le rect (converti en pixels) → CIPixellate.
    /// Pixellisation plutôt que flou gaussien : pas de fuite d'information aux bords.
    private func pixellatePatch(for rect: CGRect) -> NSImage? {
        let s = CGFloat(cgImage.width) / displaySize.width
        let px = CGRect(x: rect.minX * s, y: rect.minY * s,
                        width: rect.width * s, height: rect.height * s)
        guard px.width > 1, px.height > 1, let crop = cgImage.cropping(to: px) else { return nil }

        let ci = CIImage(cgImage: crop)
        let filter = CIFilter.pixellate()
        filter.inputImage = ci
        filter.scale = Float(max(10, px.width / 15))
        filter.center = CGPoint(x: ci.extent.midX, y: ci.extent.midY)
        guard let out = filter.outputImage?.cropped(to: ci.extent),
              let result = CIContext().createCGImage(out, from: ci.extent) else { return nil }
        return NSImage(cgImage: result, size: rect.size)
    }

    /// Export à la taille pixel d'origine (piège Retina : capture 2x).
    private func renderResult() -> NSImage? {
        focusedText = nil
        let renderer = ImageRenderer(content: annotatedContent(interactive: false))
        renderer.scale = CGFloat(cgImage.width) / displaySize.width
        return renderer.nsImage
    }

    private func saveToDesktop(_ img: NSImage) {
        guard let tiff = img.tiffRepresentation,
              let rep = NSBitmapImageRep(data: tiff),
              let png = rep.representation(using: .png, properties: [:]) else { return }
        let desktop = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask)[0]
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd 'à' HH.mm.ss"
        let dest = desktop.appendingPathComponent("Snappy \(formatter.string(from: Date())).png")
        do {
            try png.write(to: dest)
            HUD.show("Sauvé sur le bureau")
        } catch {
            NSLog("Snappy: échec sauvegarde: \(error)")
        }
    }
}
