import KeyboardShortcuts
import SwiftUI

struct HotKeysSettingsView: View {
    var body: some View {
        Form {
            PaneIntro(intro: Help.Pane.hotKeys)

            Section {
                recorder("Start or end a session", name: .toggleSession, info: Help.toggleHotKey)
                recorder("End the current session", name: .endSession, info: Help.endHotKey)
                recorder("Open settings", name: .openSettings, info: Help.settingsHotKey)
            } footer: {
                Text(Help.hotKeysFooter)
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
    }

    private func recorder(_ title: String, name: KeyboardShortcuts.Name, info: String) -> some View {
        LabeledContent {
            KeyboardShortcuts.Recorder(for: name)
        } label: {
            InfoLabel(title, info: info)
        }
        .help(info)
    }
}
