import AppKit

/// Asks which in-progress download to wait for.
@MainActor
enum DownloadPicker {
    static func choose(onPick: @escaping @MainActor (URL) -> Void) {
        let panel = NSOpenPanel()
        panel.title = "Keep Awake While Downloading"
        panel.message = "Choose the file that's downloading. Your Mac stays awake until it finishes."
        panel.prompt = "Start"
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.treatsFilePackagesAsDirectories = false
        panel.directoryURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first

        NSApp.activate()
        panel.begin { response in
            MainActor.assumeIsolated {
                guard response == .OK, let url = panel.url else { return }
                onPick(url)
            }
        }
    }
}
