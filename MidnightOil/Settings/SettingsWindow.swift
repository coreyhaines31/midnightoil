import AppKit
import MidnightOilCore
import SwiftUI

@MainActor
final class SettingsWindow {
    private let helper: HelperClient
    private var window: NSWindow?

    init(helper: HelperClient) {
        self.helper = helper
    }

    func show() {
        if window == nil {
            let view = SettingsView(helper: helper)
            let window = NSWindow(contentViewController: NSHostingController(rootView: view))
            window.title = "\(Brand.name) Settings"
            window.styleMask = [.titled, .closable]
            window.isReleasedWhenClosed = false
            window.center()
            self.window = window
        }
        NSApp.activate()
        window?.makeKeyAndOrderFront(nil)
    }
}

private struct SettingsView: View {
    let helper: HelperClient

    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem { Label("General", systemImage: "gearshape") }
            SessionSettingsView()
                .tabItem { Label("Sessions", systemImage: "timer") }
            if LidState.hasLid {
                ClosedLidSettingsView(helper: helper)
                    .tabItem { Label("Closed Lid", systemImage: "laptopcomputer") }
            }
        }
        .frame(width: 500, height: 400)
    }
}
