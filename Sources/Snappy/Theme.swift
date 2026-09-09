import AppKit
import SwiftUI

/// Palette et composants du style « site Snappy » : verre sombre, accent bleu,
/// coins de viseur. Toujours sombre, quel que soit le mode système.
enum Theme {
    static let bg = Color(hex: 0x08080A)
    static let panelOpaque = Color(hex: 0x1C1C20)
    static let panel = Color(hex: 0x1C1C20).opacity(0.72)
    static let ink = Color(hex: 0xF4F3F1)
    static let muted = Color(hex: 0x9A9793)
    static let faint = Color(hex: 0x6F6C68)
    static let line = Color.white.opacity(0.08)
    static let lineStrong = Color.white.opacity(0.14)
    static let blue = Color(hex: 0x5CA8FF)
    static let blueDeep = Color(hex: 0x1B62D0)
    static let blueMid = Color(hex: 0x2B74E0)
    static let onBlue = Color(hex: 0x06111F)
    static let annotation = Color(hex: 0xFF453A)

    static let primaryGradient = LinearGradient(colors: [blue, blueMid],
                                                startPoint: .top, endPoint: .bottom)
}

extension Color {
    init(hex: UInt32) {
        self.init(.sRGB,
                  red: Double((hex >> 16) & 0xFF) / 255,
                  green: Double((hex >> 8) & 0xFF) / 255,
                  blue: Double(hex & 0xFF) / 255,
                  opacity: 1)
    }
}

// MARK: - Fond verre sombre

/// Fond de panneau : glassEffect teinté sur macOS 26+, matériau + teinte avant,
/// opaque si `translucent` est faux. Liseré blanc 14 %, reflet haut, ombre portée.
struct DarkGlass<S: InsettableShape>: ViewModifier {
    let shape: S
    var translucent = true

    func body(content: Content) -> some View {
        content
            .background {
                fill
                    .overlay(shape.strokeBorder(Theme.lineStrong, lineWidth: 1))
                    .overlay(shape.strokeBorder(
                        LinearGradient(colors: [.white.opacity(0.12), .clear],
                                       startPoint: .top, endPoint: .center),
                        lineWidth: 1))
                    .shadow(color: .black.opacity(0.55), radius: 24, y: 12)
            }
            .environment(\.colorScheme, .dark)
    }

    @ViewBuilder private var fill: some View {
        if translucent, #available(macOS 26.0, *) {
            shape.fill(Theme.panel).background(Color.clear.glassEffect(.regular, in: shape))
        } else if translucent {
            shape.fill(.ultraThinMaterial).overlay(shape.fill(Theme.panel))
        } else {
            shape.fill(Theme.panelOpaque)
        }
    }
}

extension View {
    func darkGlass<S: InsettableShape>(_ shape: S, translucent: Bool = true) -> some View {
        modifier(DarkGlass(shape: shape, translucent: translucent))
    }
}

// MARK: - Coins de viseur

/// Quatre coins bleus, le motif de l'icône et du site. À poser en `.overlay`.
struct ViewfinderCorners: View {
    var size: CGFloat = 12
    var lineWidth: CGFloat = 2
    var inset: CGFloat = 6
    var color: Color = Theme.blue

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            Path { p in
                p.move(to: CGPoint(x: inset, y: inset + size))
                p.addLine(to: CGPoint(x: inset, y: inset))
                p.addLine(to: CGPoint(x: inset + size, y: inset))

                p.move(to: CGPoint(x: w - inset - size, y: inset))
                p.addLine(to: CGPoint(x: w - inset, y: inset))
                p.addLine(to: CGPoint(x: w - inset, y: inset + size))

                p.move(to: CGPoint(x: w - inset, y: h - inset - size))
                p.addLine(to: CGPoint(x: w - inset, y: h - inset))
                p.addLine(to: CGPoint(x: w - inset - size, y: h - inset))

                p.move(to: CGPoint(x: inset + size, y: h - inset))
                p.addLine(to: CGPoint(x: inset, y: h - inset))
                p.addLine(to: CGPoint(x: inset, y: h - inset - size))
            }
            .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Boutons

/// Tuile d'action de l'overlay : icône au-dessus du libellé, survol clair,
/// variante `active` bleue (Épingler).
struct TileButton: View {
    let title: String
    let symbol: String
    var active = false
    let action: () -> Void
    @State private var hovered = false

    init(_ title: String, symbol: String, active: Bool = false, action: @escaping () -> Void) {
        self.title = title; self.symbol = symbol; self.active = active; self.action = action
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 5) {
                Image(systemName: symbol).font(.system(size: 16, weight: .medium))
                Text(title).font(.system(size: 10.5, weight: .medium)).tracking(-0.1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8).padding(.horizontal, 4)
            .foregroundStyle(active || hovered ? .white : Theme.ink.opacity(0.85))
            .background(background, in: RoundedRectangle(cornerRadius: 10))
            .overlay(RoundedRectangle(cornerRadius: 10)
                .strokeBorder(Theme.blue.opacity(active ? 0.4 : 0), lineWidth: 1))
            .contentShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
        .onHover { hovered = $0 }
        .help(title)
    }

    private var background: Color {
        if active { return Theme.blue.opacity(0.22) }
        return Color.white.opacity(hovered ? 0.14 : 0.06)
    }
}

/// Bouton primaire bleu (Sauver, Par défaut).
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View { BodyView(configuration: configuration) }

    struct BodyView: View {
        let configuration: Configuration
        @State private var hovered = false
        var body: some View {
            configuration.label
                .font(.system(size: 13, weight: .semibold)).tracking(-0.13)
                .foregroundStyle(Theme.onBlue)
                .padding(.horizontal, 14).padding(.vertical, 7)
                .background(Theme.primaryGradient, in: RoundedRectangle(cornerRadius: 9))
                .overlay(RoundedRectangle(cornerRadius: 9)
                    .strokeBorder(.white.opacity(0.35), lineWidth: 1)
                    .mask(LinearGradient(colors: [.white, .clear], startPoint: .top, endPoint: .center)))
                .shadow(color: Theme.blue.opacity(0.25), radius: 10, y: 4)
                .brightness(hovered ? 0.06 : 0)
                .scaleEffect(configuration.isPressed ? 0.97 : 1)
                .onHover { hovered = $0 }
        }
    }
}

/// Bouton secondaire : liseré blanc, fond quasi transparent.
struct GhostButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View { BodyView(configuration: configuration) }

    struct BodyView: View {
        let configuration: Configuration
        @State private var hovered = false
        var body: some View {
            configuration.label
                .font(.system(size: 13, weight: .medium)).tracking(-0.13)
                .foregroundStyle(Theme.ink)
                .padding(.horizontal, 12).padding(.vertical, 7)
                .background(Color.white.opacity(hovered ? 0.07 : 0.035), in: RoundedRectangle(cornerRadius: 9))
                .overlay(RoundedRectangle(cornerRadius: 9).strokeBorder(Theme.lineStrong, lineWidth: 1))
                .scaleEffect(configuration.isPressed ? 0.97 : 1)
                .onHover { hovered = $0 }
        }
    }
}

/// Chip d'outil ou de segment : sélectionné = bleu 22 % + liseré bleu 40 %.
struct ChipButtonStyle: ButtonStyle {
    let selected: Bool
    func makeBody(configuration: Configuration) -> some View { BodyView(configuration: configuration, selected: selected) }

    struct BodyView: View {
        let configuration: Configuration
        let selected: Bool
        @State private var hovered = false
        var body: some View {
            configuration.label
                .font(.system(size: 11.5, weight: .medium)).tracking(-0.1)
                .foregroundStyle(selected ? .white : Theme.ink.opacity(0.85))
                .padding(.horizontal, 10).padding(.vertical, 6)
                .background(background, in: RoundedRectangle(cornerRadius: 9))
                .overlay(RoundedRectangle(cornerRadius: 9)
                    .strokeBorder(Theme.blue.opacity(selected ? 0.4 : 0), lineWidth: 1))
                .onHover { hovered = $0 }
        }
        private var background: Color {
            if selected { return Theme.blue.opacity(0.22) }
            return Color.white.opacity(hovered ? 0.12 : 0.06)
        }
    }
}

// MARK: - Petits composants

/// Touche clavier, comme le `<kbd>` du site.
struct Kbd: View {
    let text: String
    var accent = false

    init(_ text: String, accent: Bool = false) { self.text = text; self.accent = accent }

    var body: some View {
        Text(text)
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(Theme.ink)
            .frame(minWidth: 26)
            .padding(.horizontal, 7).padding(.vertical, 4)
            .background(Color.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 7))
            .overlay(RoundedRectangle(cornerRadius: 7)
                .strokeBorder(accent ? Theme.blue.opacity(0.6) : Theme.lineStrong, lineWidth: 1))
            .overlay(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 7).fill(Color.black.opacity(0.5)).frame(height: 1).padding(.horizontal, 1)
            }
    }
}

/// Titre de section en majuscules bleues.
struct Eyebrow: View {
    let text: String
    init(_ text: String) { self.text = text }
    var body: some View {
        Text(text.uppercased())
            .font(.system(size: 11, weight: .semibold))
            .tracking(0.9)
            .foregroundStyle(Theme.blue)
    }
}

// MARK: - Chrome de fenêtre

extension NSWindow {
    /// Fenêtre sombre à barre de titre transparente, feux de signalisation conservés.
    func applySnappyChrome() {
        styleMask.insert(.fullSizeContentView)
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        appearance = NSAppearance(named: .darkAqua)
        backgroundColor = NSColor(Theme.bg)
    }
}
