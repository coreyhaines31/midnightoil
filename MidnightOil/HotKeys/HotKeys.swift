import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let toggleSession = Self("toggleSession")
    static let endSession = Self("endSession")
    static let openSettings = Self("openSettings")
}

/// Wires the global hotkeys to session actions.
@MainActor
enum HotKeys {
    static func install(sessions: SessionController, openSettings: @escaping @MainActor () -> Void) {
        KeyboardShortcuts.onKeyUp(for: .toggleSession) {
            if sessions.isActive {
                sessions.end()
            } else {
                sessions.start(.indefinite)
            }
        }
        KeyboardShortcuts.onKeyUp(for: .endSession) {
            sessions.end()
        }
        KeyboardShortcuts.onKeyUp(for: .openSettings) {
            openSettings()
        }
    }
}
