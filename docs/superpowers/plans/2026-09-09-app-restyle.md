# Snappy App Restyle Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Porter le style de la landing (verre sombre, accent bleu, coins de viseur, tuiles d'action) dans l'app macOS Snappy : overlay post-capture, éditeur, réglages, HUD.

**Architecture:** Un fichier `Theme.swift` porte la palette et les composants réutilisables (fond verre sombre, coins de viseur, styles de boutons, touche `Kbd`, `Eyebrow`, chrome de fenêtre). Les vues existantes sont réécrites vue par vue en consommant ces composants, sans toucher à la logique métier (capture, presse-papier, export, raccourcis).

**Tech Stack:** Swift 6, SwiftUI + AppKit, macOS 14+ (`glassEffect` teinté sur macOS 26+ avec repli matériau), SwiftPM sans projet Xcode. Pas de cible de test dans le repo : la vérification est `swift build` sans avertissement nouveau, puis captures réelles de l'app.

**Spec:** `docs/superpowers/specs/2026-09-09-app-restyle-design.md`

## Global Constraints

- Repo `ndaen/snappy`, travailler sur une branche `app-restyle` créée depuis `main`. Commits `<type>: <description en anglais>`, une ligne, minuscules, sans `Co-Authored-By`, toujours avec pathspec explicite.
- **Fichiers interdits** (chantier vidéo non commité de Noah) : `Sources/Snappy/AppDelegate.swift`, `Sources/Snappy/CaptureService.swift`, `Sources/Snappy/Shortcuts.swift`, `Sources/Snappy/HotKeyManager.swift`. Ne jamais les modifier ni les indexer.
- Toujours sombre : chaque fenêtre force `NSAppearance(named: .darkAqua)` et chaque vue racine `.environment(\.colorScheme, .dark)`.
- Palette exacte : `bg #08080A`, `panel #1C1C20` à 72 %, `ink #F4F3F1`, `muted #9A9793`, `faint #6F6C68`, `line` blanc 8 %, `lineStrong` blanc 14 %, `blue #5CA8FF`, `blueDeep #1B62D0`, `blueMid #2B74E0`, `onBlue #06111F`, encre d'annotation `#FF453A`.
- Police système SF Pro ; `tracking(-0.02em)` sur les titres, `-0.01em` sur les libellés de boutons.
- Clé de préférence `overlay.glass` conservée ; libellé « Fond translucide ».
- Build : `arch -arm64 swift build` (RTK casse `swift test` en x86, même précaution pour le build). Aucun nouvel avertissement par rapport au build de départ.
- Captures : `.claude/screenshots/app/` dans le repo Snappy. `screencapture -x` demande la permission Enregistrement de l'écran pour le terminal ; si la capture sort noire, demander à Noah les captures plutôt que de contourner.
- Après `build-app.sh`, Noah doit re-cocher Enregistrement de l'écran pour Snappy (TCC lié au CDHash) : le dire dans le rapport.

## File Structure

| Fichier | Rôle |
|---|---|
| `Sources/Snappy/Theme.swift` (nouveau) | Palette `Theme`, `Color(hex:)`, `DarkGlass` + `.darkGlass()`, `ViewfinderCorners`, `TileButton`, `PrimaryButtonStyle`, `GhostButtonStyle`, `ChipButtonStyle`, `Kbd`, `Eyebrow`, `NSWindow.applySnappyChrome()`. |
| `Sources/Snappy/OverlayView.swift` | Vue de l'overlay réagencée (vignette + coins + 4 tuiles). `GlassBackground` supprimé. |
| `Sources/Snappy/OverlayPanel.swift` | Fondu à la fermeture, alpha remis à 1 à l'ouverture. `DraggableThumbnail` inchangé. |
| `Sources/Snappy/EditorCanvas.swift` | `EditorTool.title`, barre d'outils sombre, fond `bg`. Canevas et export inchangés. |
| `Sources/Snappy/EditorWindow.swift` | Chrome de fenêtre via `applySnappyChrome()`. |
| `Sources/Snappy/SettingsView.swift` | Cartes sombres, chips de position, toggle, bouton primaire ; fenêtre avec chrome. |
| `Sources/Snappy/ShortcutRecorder.swift` | Rendu en touches `Kbd`, logique du monitor inchangée. |
| `Sources/Snappy/OCRService.swift` | `HUD.show` en panneau verre sombre. |
| `Sources/Snappy/main.swift` | Crochet de prévisualisation `SNAPPY_PREVIEW_IMAGE` pour afficher l'overlay sans capture (vérification). |

---

### Task 1: Thème et composants

**Files:**
- Create: `Sources/Snappy/Theme.swift`

**Interfaces:**
- Produces: `enum Theme` (couleurs statiques + `primaryGradient`), `Color.init(hex: UInt32)`, `View.darkGlass(_ shape: some InsettableShape, translucent: Bool = true)`, `ViewfinderCorners(size:lineWidth:inset:color:)`, `TileButton(_ title: String, symbol: String, active: Bool = false, action: () -> Void)`, `PrimaryButtonStyle()`, `GhostButtonStyle()`, `ChipButtonStyle(selected: Bool)`, `Kbd(_ text: String, accent: Bool = false)`, `Eyebrow(_ text: String)`, `NSWindow.applySnappyChrome()`.

- [ ] **Step 1: Créer la branche et relever le build de départ**

```bash
cd ~/app-idea/snappy && git checkout -b app-restyle && arch -arm64 swift build 2>&1 | grep -c "warning:"
```
Noter le nombre d'avertissements (attendu : `0`). Ce nombre est la référence pour toutes les tâches.

- [ ] **Step 2: Écrire `Sources/Snappy/Theme.swift`**

```swift
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
            Color.clear.glassEffect(.regular.tint(Theme.panel), in: shape)
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
                Image(systemName: symbol).font(.system(size: 15, weight: .medium))
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
    func makeBody(configuration: Configuration) -> some View { Body(configuration: configuration) }

    private struct Body: View {
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
    func makeBody(configuration: Configuration) -> some View { Body(configuration: configuration) }

    private struct Body: View {
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
    func makeBody(configuration: Configuration) -> some View { Body(configuration: configuration, selected: selected) }

    private struct Body: View {
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
            .font(.system(size: 12, weight: .medium))
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
        isMovableByWindowBackground = true
    }
}
```

- [ ] **Step 3: Compiler**

```bash
cd ~/app-idea/snappy && arch -arm64 swift build 2>&1 | grep -E "error:|warning:|Build complete"
```
Attendu : `Build complete!`, même nombre d'avertissements qu'à l'étape 1. Si `glassEffect` ou `.tint` ne compile pas sur le toolchain local, remplacer la branche macOS 26 par la branche matériau (supprimer le `if #available`) et le noter dans le rapport.

- [ ] **Step 4: Commit**

```bash
cd ~/app-idea/snappy && git add Sources/Snappy/Theme.swift && git commit -m "feat: theme palette and site-style components" -- Sources/Snappy/Theme.swift
```

---

### Task 2: Overlay

**Files:**
- Modify: `Sources/Snappy/OverlayView.swift` (réécriture complète)
- Modify: `Sources/Snappy/OverlayPanel.swift` (`show`, `dismiss`)
- Modify: `Sources/Snappy/main.swift` (crochet de prévisualisation)

**Interfaces:**
- Consumes: `Theme`, `.darkGlass`, `ViewfinderCorners`, `TileButton` (Task 1). `OverlayController.shared.dismiss()/setPinned(_:)`, `DraggableThumbnail`, `CaptureService.shared.copyToPasteboard(_:)/saveToDesktop(_:)`, `EditorWindowController.shared.open(url:image:)` (existants).
- Produces: `GlassBackground` supprimé (plus aucun usage après cette tâche).

- [ ] **Step 1: Réécrire `Sources/Snappy/OverlayView.swift`**

```swift
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
        .padding(16) // marge pour l'ombre portée dans le panel transparent
        .scaleEffect(shown ? 1 : 0.85, anchor: .bottomTrailing)
        .opacity(shown ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.75)) { shown = true }
        }
    }
}
```

`saveToDesktop` retourne `URL?` (chantier vidéo en cours dans `CaptureService`), d'où le `_ =`.

- [ ] **Step 2: Fondu à la fermeture dans `OverlayPanel.swift`**

Dans `show(url:)`, juste avant `panel.orderFrontRegardless()`, ajouter :

```swift
        panel.alphaValue = 1
```

Remplacer la méthode `dismiss()` par :

```swift
    func dismiss() {
        dismissTask?.cancel()
        dismissTask = nil
        currentURL = nil
        guard let panel, panel.isVisible else { return }
        NSAnimationContext.runAnimationGroup({ ctx in
            ctx.duration = 0.15
            panel.animator().alphaValue = 0
        }, completionHandler: {
            panel.orderOut(nil)
        })
    }
```

`currentURL` est remis à nil immédiatement pour que `OCRService`/`AppDelegate` voient l'overlay comme fermé pendant le fondu (comportement identique à avant côté état).

- [ ] **Step 3: Crochet de prévisualisation dans `main.swift`**

Ajouter avant `app.run()` :

```swift
// Vérification visuelle sans capture ni permission TCC :
// SNAPPY_PREVIEW_IMAGE=/chemin/vers.png open -W /Applications/Snappy.app
if let path = ProcessInfo.processInfo.environment["SNAPPY_PREVIEW_IMAGE"] {
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        OverlayController.shared.show(url: URL(fileURLWithPath: path))
    }
}
```

- [ ] **Step 4: Compiler et vérifier visuellement**

```bash
cd ~/app-idea/snappy && arch -arm64 swift build 2>&1 | grep -E "error:|warning:|Build complete"
```
Attendu : `Build complete!`, aucun avertissement nouveau.

Prévisualisation sans installer (le binaire debug suffit pour l'overlay) :

```bash
cd ~/app-idea/snappy && cp .claude/screenshots/playwright/final-en-desktop.png /tmp/snappy-preview.png && mkdir -p .claude/screenshots/app && (SNAPPY_PREVIEW_IMAGE=/tmp/snappy-preview.png .build/debug/Snappy &) && sleep 3 && screencapture -x -R "$(python3 -c "print(f'{1440-300},{900-220},300,220')")" .claude/screenshots/app/overlay.png; pkill -x Snappy
```
Adapter le rectangle à la résolution de l'écran (`system_profiler SPDisplaysDataType | grep Resolution`) : l'overlay est en bas à droite avec 20 pt de marge (ou selon `overlay.position`). Ouvrir `overlay.png` avec Read : on doit voir la vignette avec les quatre coins bleus, la croix, et quatre tuiles avec icône et libellé sur fond charbon. Si l'image est noire, la permission manque : le dire dans le rapport et demander la capture à Noah.

- [ ] **Step 5: Commit**

```bash
cd ~/app-idea/snappy && git commit -m "feat: overlay restyled with viewfinder thumbnail and action tiles" -- Sources/Snappy/OverlayView.swift Sources/Snappy/OverlayPanel.swift Sources/Snappy/main.swift
```

---

### Task 3: Éditeur

**Files:**
- Modify: `Sources/Snappy/EditorCanvas.swift` (`EditorTool`, `body`, `toolbar`)
- Modify: `Sources/Snappy/EditorWindow.swift`

**Interfaces:**
- Consumes: `Theme`, `ChipButtonStyle`, `GhostButtonStyle`, `PrimaryButtonStyle`, `NSWindow.applySnappyChrome()` (Task 1).

- [ ] **Step 1: Ajouter `title` à `EditorTool`**

Dans `enum EditorTool`, après `var symbol`, ajouter :

```swift
    /// Libellé court des chips de la barre d'outils.
    var title: String {
        switch self {
        case .arrow: "Flèche"
        case .rect: "Cadre"
        case .highlight: "Surligner"
        case .blur: "Flou"
        case .text: "Texte"
        }
    }
```

- [ ] **Step 2: Réécrire `body` et `toolbar` de `EditorView`**

```swift
    var body: some View {
        VStack(spacing: 0) {
            toolbar
            canvas
                .frame(width: displaySize.width, height: displaySize.height)
        }
        .background(Theme.bg)
        .environment(\.colorScheme, .dark)
    }

    private var toolbar: some View {
        HStack(spacing: 6) {
            ForEach(EditorTool.allCases) { t in
                Button { tool = t } label: {
                    Label(t.title, systemImage: t.symbol)
                }
                .buttonStyle(ChipButtonStyle(selected: tool == t))
                .help(t.help)
            }

            Spacer(minLength: 16)

            Button {
                if !shapes.isEmpty { shapes.removeLast() }
            } label: {
                Label("Annuler", systemImage: "arrow.uturn.backward")
            }
            .buttonStyle(GhostButtonStyle())
            .disabled(shapes.isEmpty)
            .opacity(shapes.isEmpty ? 0.4 : 1)

            Button {
                if let img = renderResult() {
                    let pb = NSPasteboard.general
                    pb.clearContents()
                    pb.writeObjects([img])
                    HUD.show("Copié")
                }
            } label: {
                Label("Copier", systemImage: "doc.on.doc")
            }
            .buttonStyle(GhostButtonStyle())

            Button {
                if let img = renderResult() { saveToDesktop(img) }
            } label: {
                Label("Sauver", systemImage: "arrow.down.to.line")
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .labelStyle(.titleAndIcon)
        .padding(.horizontal, 14)
        .padding(.top, 28) // zone de la barre de titre transparente (feux)
        .frame(height: 80)
        .background(Theme.bg)
        .overlay(alignment: .bottom) { Rectangle().fill(Theme.line).frame(height: 1) }
    }
```

Le reste du fichier (`canvas`, `annotatedContent`, `draw`, `dragGesture`, `pixellatePatch`, `renderResult`, `saveToDesktop`) ne change pas. Dans `draw`, remplacer les deux `.color(.red)` par `.color(Theme.annotation)` et, dans `annotatedContent`, `.foregroundStyle(.red)` du `TextField` par `.foregroundStyle(Theme.annotation)`.

- [ ] **Step 3: Chrome de la fenêtre dans `EditorWindow.swift`**

Remplacer la ligne `w.title = "Snappy — Annotation"` par :

```swift
        w.title = "Snappy — Annotation"
        w.applySnappyChrome()
```

- [ ] **Step 4: Compiler et vérifier**

```bash
cd ~/app-idea/snappy && arch -arm64 swift build 2>&1 | grep -E "error:|warning:|Build complete"
```
Attendu : `Build complete!`, aucun avertissement nouveau.

Prévisualisation : lancer comme à la tâche 2 avec `SNAPPY_PREVIEW_IMAGE`, cliquer « Annoter » dans l'overlay (ou, si le clic est impossible en automatisé, laisser Noah le faire), capturer la fenêtre de l'éditeur : `screencapture -x -l $(osascript -e 'tell app "System Events" to id of window 1 of process "Snappy"') .claude/screenshots/app/editor.png` (si `-l` échoue, capturer tout l'écran et recadrer avec `sips -c`). Attendu à la lecture : barre sombre continue sous les feux, cinq chips avec la sélection bleue, Annuler et Copier en ghost, Sauver en bleu.

- [ ] **Step 5: Commit**

```bash
cd ~/app-idea/snappy && git commit -m "feat: dark editor toolbar and window chrome" -- Sources/Snappy/EditorCanvas.swift Sources/Snappy/EditorWindow.swift
```

---

### Task 4: Réglages et enregistreur de raccourcis

**Files:**
- Modify: `Sources/Snappy/SettingsView.swift` (réécriture de `SettingsView`, chrome dans `SettingsWindowController.open`)
- Modify: `Sources/Snappy/ShortcutRecorder.swift` (`body` seulement)

**Interfaces:**
- Consumes: `Theme`, `Eyebrow`, `Kbd`, `ChipButtonStyle`, `PrimaryButtonStyle`, `NSWindow.applySnappyChrome()` (Task 1). `ShortcutStore.shared`, `SnapAction.allCases`, `OverlayPosition` (existants, non modifiés).

- [ ] **Step 1: Réécrire `SettingsView`**

```swift
struct SettingsView: View {
    @ObservedObject private var store = ShortcutStore.shared
    @AppStorage("overlay.position") private var overlayPosition = OverlayPosition.right.rawValue
    @AppStorage("overlay.glass") private var translucent = true

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            card("Raccourcis") {
                ForEach(SnapAction.allCases) { action in
                    HStack {
                        Text(action.title).foregroundStyle(Theme.ink)
                        Spacer()
                        ShortcutRecorderView(action: action)
                    }
                    if action != SnapAction.allCases.last {
                        Rectangle().fill(Theme.line).frame(height: 1)
                    }
                }
            }

            card("Overlay") {
                HStack {
                    Text("Position en bas de l'écran").foregroundStyle(Theme.ink)
                    Spacer()
                    HStack(spacing: 4) {
                        ForEach(OverlayPosition.allCases) { p in
                            Button(p.title) { overlayPosition = p.rawValue }
                                .buttonStyle(ChipButtonStyle(selected: overlayPosition == p.rawValue))
                        }
                    }
                }
                Rectangle().fill(Theme.line).frame(height: 1)
                Toggle("Fond translucide", isOn: $translucent)
                    .toggleStyle(.switch)
                    .tint(Theme.blue)
                    .foregroundStyle(Theme.ink)
            }

            card("macOS") {
                HStack(alignment: .top, spacing: 14) {
                    Button("Par défaut") { store.adoptSystemShortcuts() }
                        .buttonStyle(PrimaryButtonStyle())
                    Text("Remplace les raccourcis capture de macOS (⌘⇧3, ⌘⇧4…) par ceux de Snappy. Réversible dans Réglages Système › Clavier › Raccourcis › Captures d'écran.")
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.faint)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(.top, 36) // barre de titre transparente
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
        .frame(width: 460)
        .background(Theme.bg)
        .environment(\.colorScheme, .dark)
        .fixedSize(horizontal: false, vertical: true)
    }

    private func card<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Eyebrow(title)
            content()
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.035), in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Theme.line, lineWidth: 1))
    }
}
```

`SnapAction` doit être `Equatable` pour `action != SnapAction.allCases.last` : c'est un `enum` avec `rawValue`, donc déjà `Equatable`. Si `SnapAction.allCases.last` est optionnel (c'est le cas), écrire `action != SnapAction.allCases.last!` n'est pas acceptable : utiliser `if action.id != SnapAction.allCases.last?.id`.

- [ ] **Step 2: Chrome de la fenêtre**

Dans `SettingsWindowController.open()`, après `w.title = "Réglages Snappy"`, ajouter `w.applySnappyChrome()`.

- [ ] **Step 3: Rendu `Kbd` dans `ShortcutRecorderView`**

Remplacer `body` par :

```swift
    var body: some View {
        Button {
            recording ? stopRecording() : startRecording()
        } label: {
            HStack(spacing: 4) {
                if recording {
                    Kbd("Tapez…", accent: true)
                } else if let label = store.shortcuts[action]?.label {
                    ForEach(Array(keys(label).enumerated()), id: \.offset) { _, k in Kbd(k) }
                } else {
                    Kbd("—")
                }
            }
        }
        .buttonStyle(.plain)
        .help(recording ? "Échap pour annuler" : "Cliquer pour changer le raccourci")
        .onDisappear { stopRecording() }
    }

    /// « ⌃⌥⇧⌘K » → ["⌃", "⌥", "⇧", "⌘", "K"] : une touche par modificateur, le reste groupé.
    private func keys(_ label: String) -> [String] {
        var out: [String] = []
        var rest = ""
        for ch in label {
            if "⌃⌥⇧⌘".contains(ch) { out.append(String(ch)) } else { rest.append(ch) }
        }
        if !rest.isEmpty { out.append(rest) }
        return out
    }
```

`startRecording`/`stopRecording` inchangés.

- [ ] **Step 4: Compiler et vérifier**

```bash
cd ~/app-idea/snappy && arch -arm64 swift build 2>&1 | grep -E "error:|warning:|Build complete"
```
Attendu : `Build complete!`, aucun avertissement nouveau.

Prévisualisation : lancer `.build/debug/Snappy`, ouvrir Réglages depuis le menu de la barre de menus (ou `osascript -e 'tell application "System Events" to tell process "Snappy" to click menu bar item 1 of menu bar 2'` puis cliquer « Réglages… »), capturer `.claude/screenshots/app/settings.png`. Attendu : trois cartes sombres, eyebrows bleus, raccourcis en touches, chips de position, bouton bleu.

- [ ] **Step 5: Commit**

```bash
cd ~/app-idea/snappy && git commit -m "feat: dark settings cards and kbd shortcut recorder" -- Sources/Snappy/SettingsView.swift Sources/Snappy/ShortcutRecorder.swift
```

---

### Task 5: HUD

**Files:**
- Modify: `Sources/Snappy/OCRService.swift` (corps de `HUD.show`, vue seulement)

**Interfaces:**
- Consumes: `Theme`, `.darkGlass` (Task 1).

- [ ] **Step 1: Remplacer la vue du HUD**

Dans `HUD.show`, remplacer le bloc `let view = NSHostingView(rootView: … )` par :

```swift
        let view = NSHostingView(rootView:
            HStack(spacing: 8) {
                Image(systemName: symbol).foregroundStyle(Theme.blue)
                Text(message).foregroundStyle(Theme.ink)
            }
            .font(.system(size: 13, weight: .medium))
            .padding(.horizontal, 14).padding(.vertical, 9)
            .darkGlass(RoundedRectangle(cornerRadius: 12))
            .padding(16)
        )
```

Le panel HUD a `hasShadow = false` : l'ombre vient du `darkGlass`, d'où le padding de 16 pour ne pas la rogner.

- [ ] **Step 2: Compiler et vérifier**

```bash
cd ~/app-idea/snappy && arch -arm64 swift build 2>&1 | grep -E "error:|warning:|Build complete"
```
Attendu : `Build complete!`, aucun avertissement nouveau. Vérification visuelle : dans l'éditeur ouvert, cliquer « Copier » fait apparaître le HUD « Copié » en bas de l'écran ; capturer `.claude/screenshots/app/hud.png`.

- [ ] **Step 3: Commit**

```bash
cd ~/app-idea/snappy && git commit -m "feat: hud in dark glass" -- Sources/Snappy/OCRService.swift
```

---

### Task 6: Installation, contrôle de bout en bout, mémoire

**Files:**
- Aucun fichier source. Captures dans `.claude/screenshots/app/`. Mémoire projet.

- [ ] **Step 1: Contrôle des fichiers interdits**

```bash
cd ~/app-idea/snappy && git log --oneline main..HEAD -- Sources/Snappy/AppDelegate.swift Sources/Snappy/CaptureService.swift Sources/Snappy/Shortcuts.swift Sources/Snappy/HotKeyManager.swift | wc -l && grep -rn "GlassBackground" Sources/Snappy | wc -l
```
Attendu : `0` et `0`.

- [ ] **Step 2: Installer l'app**

```bash
cd ~/app-idea/snappy && bash scripts/build-app.sh 2>&1 | tail -4
```
Attendu : `✅ /Applications/Snappy.app installé.` Prévenir Noah : re-cocher Enregistrement de l'écran pour Snappy.

- [ ] **Step 3: Parcours réel**

Avec l'app installée et la permission re-cochée par Noah : faire une capture de zone via le raccourci, vérifier l'overlay (aspect + glisser-déposer de la vignette vers le Finder), Épingler (l'overlay ne se ferme plus après 6 s), Copier (image dans le presse-papier), Annoter (éditeur sombre, flèche rouge, Sauver écrit un PNG sur le bureau), Réglages. Prendre `overlay.png`, `editor.png`, `settings.png`, `hud.png` dans `.claude/screenshots/app/` s'ils manquent encore, et les relire une par une à côté de `.claude/screenshots/playwright/final-en-desktop.png` pour comparer l'overlay au site.

- [ ] **Step 4: Mémoire**

Mettre à jour `~/.claude/projects/-Users-ndaen-app-idea/memory/snappy-project.md` : style de l'app aligné sur le site (branche `app-restyle`, fichier `Theme.swift`, crochet `SNAPPY_PREVIEW_IMAGE`), et la contrainte « fichiers du chantier vidéo interdits tant que non commités ».

- [ ] **Step 5: Remise à Noah**

Ne pas merger ni pousser : rapporter la liste des commits de `app-restyle`, les captures, et laisser Noah merger dans `main` une fois son chantier vidéo commité.
