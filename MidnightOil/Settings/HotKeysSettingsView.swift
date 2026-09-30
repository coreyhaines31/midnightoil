import KeyboardShortcuts
import SwiftUI

struct HotKeysSettingsView: View {
    var body: some View {
        Form {
            Section {
                KeyboardShortcuts.Recorder("Start or end a session", name: .toggleSession)
                KeyboardShortcuts.Recorder("End the current session", name: .endSession)
                KeyboardShortcuts.Recorder("Open settings", name: .openSettings)
            } footer: {
                Text("Hotkeys work in any app. Click a field and press the keys you want.")
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
    }
}
