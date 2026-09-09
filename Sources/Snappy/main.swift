import AppKit

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory) // LSUIElement : pas de Dock, barre de menu seulement

// Vérification visuelle sans capture ni permission TCC (debug uniquement) :
// SNAPPY_PREVIEW_IMAGE=/chemin/vers.png open -W /Applications/Snappy.app
// SNAPPY_PREVIEW_SETTINGS=1 open -W /Applications/Snappy.app
#if DEBUG
if let path = ProcessInfo.processInfo.environment["SNAPPY_PREVIEW_IMAGE"] {
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        OverlayController.shared.show(url: URL(fileURLWithPath: path))
    }
}

if ProcessInfo.processInfo.environment["SNAPPY_PREVIEW_SETTINGS"] != nil {
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        SettingsWindowController.shared.open()
    }
}
#endif

app.run()
