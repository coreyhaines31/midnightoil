import AppKit
import MidnightOilCore
import SwiftUI

@MainActor
final class SettingsWindow {
    private let helper: HelperClient
    private let triggers: TriggerStore
    private let history: SessionHistory
    private var window: NSWindow?

    init(helper: HelperClient, triggers: TriggerStore, history: SessionHistory) {
        self.helper = helper
        self.triggers = triggers
        self.history = history
    }

    func show() {
        if window == nil {
            let view = SettingsView(helper: helper, triggers: triggers, history: history)
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
    let history: SessionHistory

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
            NotificationsSettingsView()
                .tabItem { Label("Notifications", systemImage: "bell") }
            AppearanceSettingsView()
                .tabItem { Label("Appearance", systemImage: "paintbrush") }
            StatisticsSettingsView(history: history)
                .tabItem { Label("Statistics", systemImage: "chart.bar") }
        }
        .frame(width: 780, height: 460)
    }
}
