import AppKit
import Carbon.HIToolbox

struct Shortcut: Codable, Equatable {
    var keyCode: UInt32
    var carbonModifiers: UInt32   // cmdKey | shiftKey | optionKey | controlKey
    var label: String             // ex. "⌘⇧4"

    static func label(modifiers: NSEvent.ModifierFlags, key: String) -> String {
        var s = ""
        if modifiers.contains(.control) { s += "⌃" }
        if modifiers.contains(.option) { s += "⌥" }
        if modifiers.contains(.shift) { s += "⇧" }
        if modifiers.contains(.command) { s += "⌘" }
        return s + key.uppercased()
    }

    static func carbonModifiers(from flags: NSEvent.ModifierFlags) -> UInt32 {
        var m: UInt32 = 0
        if flags.contains(.command) { m |= UInt32(cmdKey) }
        if flags.contains(.shift) { m |= UInt32(shiftKey) }
        if flags.contains(.option) { m |= UInt32(optionKey) }
        if flags.contains(.control) { m |= UInt32(controlKey) }
        return m
    }
}

enum SnapAction: String, CaseIterable, Identifiable {
    case zone, screen, ocr, video
    var id: String { rawValue }

    var title: String {
        switch self {
        case .zone: "Capturer une zone / fenêtre"
        case .screen: "Capturer l'écran"
        case .ocr: "Copier le texte (OCR)"
        case .video: "Enregistrer une vidéo"
        }
    }

    /// Raccourcis initiaux, sans conflit avec ceux de macOS.
    var defaultShortcut: Shortcut {
        switch self {
        case .zone: Shortcut(keyCode: UInt32(kVK_ANSI_1), carbonModifiers: cmdShift, label: "⌘⇧1")
        case .screen: Shortcut(keyCode: UInt32(kVK_ANSI_2), carbonModifiers: cmdShift, label: "⌘⇧2")
        case .ocr: Shortcut(keyCode: UInt32(kVK_ANSI_0), carbonModifiers: cmdShift, label: "⌘⇧0")
        case .video: Shortcut(keyCode: UInt32(kVK_ANSI_9), carbonModifiers: cmdShift, label: "⌘⇧9")
        }
    }

    /// Raccourcis « Par défaut » qui remplacent ceux de macOS.
    var systemReplacement: Shortcut {
        switch self {
        case .zone: Shortcut(keyCode: UInt32(kVK_ANSI_4), carbonModifiers: cmdShift, label: "⌘⇧4")
        case .screen: Shortcut(keyCode: UInt32(kVK_ANSI_3), carbonModifiers: cmdShift, label: "⌘⇧3")
        case .ocr: Shortcut(keyCode: UInt32(kVK_ANSI_2), carbonModifiers: cmdShift, label: "⌘⇧2")
        case .video: Shortcut(keyCode: UInt32(kVK_ANSI_5), carbonModifiers: cmdShift, label: "⌘⇧5")
        }
    }
}

/// Persistance UserDefaults + application à chaud via HotKeyManager.
@MainActor
final class ShortcutStore: ObservableObject {
    static let shared = ShortcutStore()

    @Published private(set) var shortcuts: [SnapAction: Shortcut] = [:]

    private init() {
        for action in SnapAction.allCases {
            if let data = UserDefaults.standard.data(forKey: key(action)),
               let s = try? JSONDecoder().decode(Shortcut.self, from: data) {
                shortcuts[action] = s
            } else {
                shortcuts[action] = action.defaultShortcut
            }
        }
    }

    func set(_ shortcut: Shortcut, for action: SnapAction) {
        shortcuts[action] = shortcut
        if let data = try? JSONEncoder().encode(shortcut) {
            UserDefaults.standard.set(data, forKey: key(action))
        }
        apply()
    }

    /// (Ré)enregistre tous les raccourcis Carbon.
    func apply() {
        HotKeyManager.shared.unregisterAll()
        for action in SnapAction.allCases {
            guard let s = shortcuts[action] else { continue }
            HotKeyManager.shared.register(keyCode: s.keyCode, modifiers: s.carbonModifiers) {
                AppActions.perform(action)
            }
        }
    }

    /// Bouton « Par défaut » : désactive les raccourcis capture de macOS
    /// (symbolic hotkeys 28–31 : ⌘⇧3/4 + variantes presse-papier, 184 : ⌘⇧5) et prend leur place.
    func adoptSystemShortcuts() {
        for id in [28, 29, 30, 31, 184] {
            run("/usr/bin/defaults", ["write", "com.apple.symbolichotkeys", "AppleSymbolicHotKeys",
                                      "-dict-add", "\(id)", "<dict><key>enabled</key><false/></dict>"])
        }
        // Applique les changements sans déconnexion (binaire système standard pour ça).
        run("/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings", ["-u"])
        for action in SnapAction.allCases {
            set(action.systemReplacement, for: action)
        }
    }

    private func key(_ action: SnapAction) -> String { "shortcut.\(action.rawValue)" }

    private func run(_ path: String, _ args: [String]) {
        let p = Process()
        p.executableURL = URL(fileURLWithPath: path)
        p.arguments = args
        try? p.run()
        p.waitUntilExit()
    }
}
