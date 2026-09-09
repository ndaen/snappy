import AppKit

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory) // LSUIElement : pas de Dock, barre de menu seulement

// Vérification visuelle sans capture ni permission TCC :
// SNAPPY_PREVIEW_IMAGE=/chemin/vers.png open -W /Applications/Snappy.app
if let path = ProcessInfo.processInfo.environment["SNAPPY_PREVIEW_IMAGE"] {
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        OverlayController.shared.show(url: URL(fileURLWithPath: path))
    }
}

app.run()
