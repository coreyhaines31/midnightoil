import AppKit
import SwiftUI

struct AppearanceSettingsView: View {
    @AppStorage(Preferences.Key.statusIconStyle) private var style = StatusIcon.Style.flame.rawValue
    @AppStorage(Preferences.Key.customIconsAreTemplates) private var templates = true {
        didSet { StatusIcon.invalidateCache() }
    }
    @AppStorage(Preferences.Key.showsRemainingInMenuBar) private var showsRemainingInMenuBar = false
    /// Bumped after choosing or clearing an image so the previews reload.
    @State private var revision = 0

    var body: some View {
        Form {
            PaneIntro(intro: Help.Pane.appearance)
            ManagedNotice(keys: [
                Preferences.Key.statusIconStyle,
                Preferences.Key.showsRemainingInMenuBar,
                Preferences.Key.customIconsAreTemplates
            ])

            Section {
                Picker(selection: $style) {
                    Text("Flame").tag(StatusIcon.Style.flame.rawValue)
                    Text("Custom images").tag(StatusIcon.Style.custom.rawValue)
                } label: {
                    InfoLabel("Menu bar icon", info: Help.menuBarIcon)
                }
                .help(Help.menuBarIcon)
                .managed(Preferences.Key.statusIconStyle)
                Toggle(isOn: $showsRemainingInMenuBar) {
                    InfoLabel("Show time remaining next to the icon", info: Help.showRemaining)
                }
                .help(Help.showRemaining)
                .managed(Preferences.Key.showsRemainingInMenuBar)
            }

            if style == StatusIcon.Style.custom.rawValue {
                Section {
                    iconRow("When your Mac can sleep", state: .inactive)
                    iconRow("During a session", state: .active)
                    Toggle(isOn: $templates) { InfoLabel("Treat images as templates", info: Help.templates) }
                        .help(Help.templates)
                        .managed(Preferences.Key.customIconsAreTemplates)
                } header: {
                    InfoLabel("Custom images", info: Help.customImages)
                }
            }
        }
        .formStyle(.grouped)
    }

    private func iconRow(_ title: String, state: StatusIcon.State) -> some View {
        LabeledContent(title) {
            HStack {
                Group {
                    if let image = StatusIcon.customImage(for: state) {
                        Image(nsImage: image)
                    } else {
                        Image(systemName: "photo").foregroundStyle(.tertiary)
                    }
                }
                .frame(width: 32, height: 24)
                .id(revision)
                Button("Choose…") { choose(for: state) }
                Button("Clear") {
                    StatusIcon.clearCustomImage(for: state)
                    StatusIcon.invalidateCache()
                    revision += 1
                }
            }
        }
    }

    private func choose(for state: StatusIcon.State) {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.png, .jpeg, .tiff, .pdf, .heic]
        panel.message = "Choose an image for the \(state.rawValue) icon. Roughly 18 points tall works best."
        NSApp.activate()
        guard panel.runModal() == .OK, let url = panel.url else { return }
        do {
            try StatusIcon.setCustomImage(url, for: state)
            StatusIcon.invalidateCache()
            revision += 1
        } catch {
            NSAlert(error: error).runModal()
        }
    }
}
