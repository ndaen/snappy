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
            Text(recording ? "Tapez le raccourci…" : (store.shortcuts[action]?.label ?? "—"))
                .frame(minWidth: 110)
        }
        .onDisappear { stopRecording() }
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
