import AppKit
import SwiftUI

/// Standard macOS preferences window: icon tabs in the toolbar, the pane's
/// name as the window title, and the window sized to each pane.
@MainActor
final class SettingsWindow {
    static let paneWidth: CGFloat = 720

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
            window = makeWindow()
        }
        NSApp.activate()
        window?.makeKeyAndOrderFront(nil)
    }

    private func makeWindow() -> NSWindow {
        let tabs = SettingsTabController()
        tabs.tabStyle = .toolbar
        tabs.add("General", symbol: "gearshape", view: GeneralSettingsView())
        tabs.add("Sessions", symbol: "timer", view: SessionSettingsView())
        tabs.add("Triggers", symbol: "bolt", view: TriggersSettingsView(store: triggers))
        if LidState.hasLid {
            tabs.add("Closed Lid", symbol: "laptopcomputer", view: ClosedLidSettingsView(helper: helper))
        }
        tabs.add("Drive Alive", symbol: "externaldrive", view: DriveAliveSettingsView())
        tabs.add("Hot Keys", symbol: "keyboard", view: HotKeysSettingsView())
        tabs.add("Notifications", symbol: "bell", view: NotificationsSettingsView())
        tabs.add("Appearance", symbol: "paintbrush", view: AppearanceSettingsView())
        tabs.add("Statistics", symbol: "chart.bar", view: StatisticsSettingsView(history: history))

        let window = NSWindow(contentViewController: tabs)
        window.styleMask = [.titled, .closable]
        window.toolbarStyle = .preference
        window.isReleasedWhenClosed = false
        window.center()
        return window
    }
}

private final class SettingsTabController: NSTabViewController {
    func add(_ title: String, symbol: String, view: some View) {
        let controller = NSHostingController(rootView: view.frame(width: SettingsWindow.paneWidth))
        controller.sizingOptions = .preferredContentSize
        controller.title = title
        let item = NSTabViewItem(viewController: controller)
        item.label = title
        item.image = NSImage(systemSymbolName: symbol, accessibilityDescription: title)
        addTabViewItem(item)
    }
}
