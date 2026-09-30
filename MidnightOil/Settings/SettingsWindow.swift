import AppKit
import MidnightOilCore
import SwiftUI

@MainActor
final class SettingsWindow {
    private let helper: HelperClient
    private let triggers: TriggerStore
    private var window: NSWindow?

    init(helper: HelperClient, triggers: TriggerStore) {
        self.helper = helper
        self.triggers = triggers
    }

    func show() {
        if window == nil {
            let view = SettingsView(helper: helper, triggers: triggers)
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
    let triggers: TriggerStore

    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem { Label("General", systemImage: "gearshape") }
            SessionSettingsView()
                .tabItem { Label("Sessions", systemImage: "timer") }
            TriggersSettingsView(store: triggers)
                .tabItem { Label("Triggers", systemImage: "bolt") }
            if LidState.hasLid {
                ClosedLidSettingsView(helper: helper)
                    .tabItem { Label("Closed Lid", systemImage: "laptopcomputer") }
            }
            DriveAliveSettingsView()
                .tabItem { Label("Drive Alive", systemImage: "externaldrive") }
            HotKeysSettingsView()
                .tabItem { Label("Hot Keys", systemImage: "keyboard") }
        }
        .frame(width: 500, height: 400)
    }
}
