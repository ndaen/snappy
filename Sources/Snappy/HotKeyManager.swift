import AppKit
import Carbon.HIToolbox

let cmdShift = UInt32(cmdKey | shiftKey)

/// Raccourcis globaux via Carbon RegisterEventHotKey : aucune permission TCC,
/// et l'événement est consommé (ne fuit pas vers l'app active).
@MainActor
final class HotKeyManager {
    static let shared = HotKeyManager()

    private var actions: [UInt32: () -> Void] = [:]
    private var refs: [UInt32: EventHotKeyRef] = [:]
    private var nextId: UInt32 = 1
    private var handlerInstalled = false

    func register(keyCode: UInt32, modifiers: UInt32, action: @escaping () -> Void) {
        installHandlerIfNeeded()
        let id = nextId
        nextId += 1
        var ref: EventHotKeyRef?
        let hotKeyID = EventHotKeyID(signature: OSType(0x534E5059) /* 'SNPY' */, id: id)
        let status = RegisterEventHotKey(keyCode, modifiers, hotKeyID,
                                         GetApplicationEventTarget(), 0, &ref)
        guard status == noErr, let ref else {
            NSLog("Snappy: échec RegisterEventHotKey (\(status)) pour keyCode \(keyCode)")
            return
        }
        actions[id] = action
        refs[id] = ref
    }

    func unregisterAll() {
        refs.values.forEach { UnregisterEventHotKey($0) }
        refs.removeAll()
        actions.removeAll()
    }

    fileprivate func handle(id: UInt32) {
        actions[id]?()
    }

    private func installHandlerIfNeeded() {
        guard !handlerInstalled else { return }
        handlerInstalled = true
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard),
                                      eventKind: UInt32(kEventHotKeyPressed))
        InstallEventHandler(GetApplicationEventTarget(), { _, event, _ -> OSStatus in
            var hotKeyID = EventHotKeyID()
            GetEventParameter(event, EventParamName(kEventParamDirectObject),
                              EventParamType(typeEventHotKeyID), nil,
                              MemoryLayout<EventHotKeyID>.size, nil, &hotKeyID)
            // Le handler Carbon tourne sur le main thread.
            MainActor.assumeIsolated {
                HotKeyManager.shared.handle(id: hotKeyID.id)
            }
            return noErr
        }, 1, &eventType, nil, nil)
    }
}
