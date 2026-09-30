import AppKit
import MidnightOilCore

/// Owns the menu bar icon. It stays a plain `NSStatusItem` with an `autosaveName`
/// (no custom view, never recreated) so macOS can Cmd-drag it and remember its position.
@MainActor
final class StatusItemController: NSObject, NSMenuDelegate {
    private static let minuteChoices = [5, 10, 15, 30, 45]
    private static let hourChoices = [1, 2, 3, 4, 6, 8, 12]
    private static let extendChoices = [5, 15, 30, 60, 120]

    private let statusItem: NSStatusItem
    private let sessions: SessionController
    private let customEndWindow = CustomEndWindow()
    private let settingsWindow = SettingsWindow()
    /// The countdown line in the open menu, retitled every tick so it stays live.
    private weak var detailsItem: NSMenuItem?

    init(sessions: SessionController) {
        self.sessions = sessions
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        super.init()

        statusItem.autosaveName = "MidnightOilStatusItem"
        let menu = NSMenu()
        menu.delegate = self
        statusItem.menu = menu

        statusItem.button?.imagePosition = .imageLeading
        sessions.onChange = { [weak self] in self?.refreshButton() }
        NotificationCenter.default.addObserver(
            forName: UserDefaults.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated { self?.refreshButton() }
        }
        refreshButton()
    }

    private func refreshButton() {
        let symbol = sessions.isActive ? "flame.fill" : "flame"
        let image = NSImage(systemSymbolName: symbol, accessibilityDescription: Brand.name)
        image?.isTemplate = true
        statusItem.button?.image = image

        var title = ""
        if Preferences.showsRemainingInMenuBar, let remaining = sessions.session?.remaining(at: .now) {
            title = " " + RemainingTime.short(remaining)
        }
        if statusItem.button?.title != title {
            statusItem.button?.title = title
        }
        if let session = sessions.session {
            detailsItem?.title = Self.describe(session)
        }
    }

    // MARK: - Menu

    func menuNeedsUpdate(_ menu: NSMenu) {
        menu.removeAllItems()

        if let session = sessions.session {
            addCurrentSessionItems(for: session, to: menu)
            menu.addItem(.separator())
        }

        menu.addItem(.sectionHeader(title: "Start New Session"))
        menu.addItem(startItem("Indefinitely", end: .indefinite, keyEquivalent: "i"))
        menu.addItem(submenuItem("Minutes", items: Self.minuteChoices.map {
            startItem(Self.durationTitle(minutes: $0), end: .after(TimeInterval($0 * 60)))
        }))
        menu.addItem(submenuItem("Hours", items: Self.hourChoices.map {
            startItem(Self.durationTitle(minutes: $0 * 60), end: .after(TimeInterval($0 * 3_600)))
        }))
        menu.addItem(submenuItem("Until", items: untilItems()))

        menu.addItem(.separator())
        menu.addItem(ClosureMenuItem("Settings…", keyEquivalent: ",") { [weak self] in
            self?.settingsWindow.show()
        })
        menu.addItem(ClosureMenuItem("About \(Brand.name)") {
            NSApp.activate()
            NSApp.orderFrontStandardAboutPanel(nil)
        })
        menu.addItem(.separator())
        menu.addItem(ClosureMenuItem("Quit \(Brand.name)", keyEquivalent: "q") {
            NSApp.terminate(nil)
        })
    }

    private func addCurrentSessionItems(for session: Session, to menu: NSMenu) {
        menu.addItem(.sectionHeader(title: "Current Session"))
        let details = NSMenuItem(title: Self.describe(session), action: nil, keyEquivalent: "")
        details.isEnabled = false
        menu.addItem(details)
        detailsItem = details

        let displaySleep = ClosureMenuItem("Allow Display Sleep") { [weak self] in
            self?.sessions.setAllowsDisplaySleep(!session.allowsDisplaySleep)
        }
        displaySleep.state = session.allowsDisplaySleep ? .on : .off
        menu.addItem(displaySleep)

        if session.endDate != nil {
            menu.addItem(submenuItem("Extend Session", items: Self.extendChoices.map { minutes in
                ClosureMenuItem("+ " + Self.durationTitle(minutes: minutes)) { [weak self] in
                    self?.sessions.extend(by: TimeInterval(minutes * 60))
                }
            }))
        }

        menu.addItem(ClosureMenuItem("End Current Session", keyEquivalent: "x") { [weak self] in
            self?.sessions.end()
        })
    }

    private func untilItems() -> [NSMenuItem] {
        var items = UntilTimes.upcomingHours(after: .now, count: 8).map { date in
            startItem(Self.clockTime(date), end: .until(date))
        }
        items.append(.separator())
        items.append(ClosureMenuItem("Other Time…") { [weak self] in
            self?.customEndWindow.show { date in self?.sessions.start(.until(date)) }
        })
        return items
    }

    private func startItem(_ title: String, end: SessionEnd, keyEquivalent: String = "") -> NSMenuItem {
        ClosureMenuItem(title, keyEquivalent: keyEquivalent) { [weak self] in self?.sessions.start(end) }
    }

    private static func durationTitle(minutes: Int) -> String {
        switch minutes {
        case 60: "1 hour"
        case let minutes where minutes % 60 == 0: "\(minutes / 60) hours"
        default: "\(minutes) minutes"
        }
    }

    private func submenuItem(_ title: String, items: [NSMenuItem]) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: nil, keyEquivalent: "")
        let submenu = NSMenu()
        items.forEach(submenu.addItem)
        item.submenu = submenu
        return item
    }

    private static func describe(_ session: Session) -> String {
        guard let endDate = session.endDate, let remaining = session.remaining(at: .now) else {
            return "Running until you end it"
        }
        return "\(RemainingTime.detailed(remaining)) remaining (\(clockTime(endDate)))"
    }

    /// "5:00 PM" today, "Wed 1:00 AM" on another day.
    private static func clockTime(_ date: Date) -> String {
        date.formatted(Calendar.current.isDateInToday(date)
            ? .dateTime.hour().minute()
            : .dateTime.weekday(.abbreviated).hour().minute())
    }
}
