import AppKit
import SwiftUI

struct AppearanceSettingsView: View {
    @AppStorage(Preferences.Key.statusIconStyle) private var style = StatusIcon.Style.lamp.rawValue
    @AppStorage(Preferences.Key.customIconsAreTemplates) private var templates = true {
        didSet { StatusIcon.invalidateCache() }
    }
    @AppStorage(Preferences.Key.showsRemainingInMenuBar) private var showsRemainingInMenuBar = false
    /// Bumped after choosing or clearing an image so the previews reload.
    @State private var revision = 0

    var body: some View {
        Form {
            Section {
                Picker("Menu bar icon", selection: $style) {
                    Text("Oil lamp").tag(StatusIcon.Style.lamp.rawValue)
                    Text("Flame").tag(StatusIcon.Style.flame.rawValue)
                    Text("Custom images").tag(StatusIcon.Style.custom.rawValue)
                }
                Toggle("Show time remaining next to the icon", isOn: $showsRemainingInMenuBar)
            }

            if style == StatusIcon.Style.custom.rawValue {
                Section {
                    iconRow("Inactive", state: .inactive)
                    iconRow("Active", state: .active)
                    Toggle("Treat images as templates", isOn: $templates)
                } footer: {
                    Text("""
                        Templates are recolored to match the menu bar, so use black shapes on a \
                        transparent background. Turn this off for full-color images.
                        """)
                    .foregroundStyle(.secondary)
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
