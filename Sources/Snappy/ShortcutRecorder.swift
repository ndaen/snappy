import SwiftUI
import Carbon.HIToolbox

/// Champ de saisie de raccourci : clic → capture la prochaine combinaison
/// tapée via un NSEvent local monitor. Échap annule.
struct ShortcutRecorderView: View {
    let action: SnapAction
    @ObservedObject private var store = ShortcutStore.shared
    @State private var recording = false
    @State private var monitor: Any?

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

    private func startRecording() {
        recording = true
        monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            if event.keyCode == UInt16(kVK_Escape) {
                stopRecording()
                return nil
            }
            let flags = event.modifierFlags.intersection([.command, .shift, .option, .control])
            guard !flags.isEmpty, let key = event.charactersIgnoringModifiers, !key.isEmpty else {
                return nil // exige au moins un modificateur
            }
            let shortcut = Shortcut(
                keyCode: UInt32(event.keyCode),
                carbonModifiers: Shortcut.carbonModifiers(from: flags),
                label: Shortcut.label(modifiers: flags, key: key)
            )
            store.set(shortcut, for: action)
            stopRecording()
            return nil
        }
    }

    private func stopRecording() {
        recording = false
        if let monitor { NSEvent.removeMonitor(monitor) }
        monitor = nil
    }
}
