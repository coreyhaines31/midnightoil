import AppKit
import MidnightOilCore

/// Owns the menu bar icon. It stays a plain `NSStatusItem` with an `autosaveName`
/// (no custom view, never recreated) so macOS can Cmd-drag it and remember its position.
@MainActor
final class StatusItemController: NSObject, NSMenuDelegate {
    private static let minuteChoices = [5, 10, 15, 30, 45]
    private static let hourChoices = [1, 2, 3, 4, 6, 8, 12]

    private let statusItem: NSStatusItem
    private let sessions: SessionController
    private let customEndWindow = CustomEndWindow()

    init(sessions: SessionController) {
        self.sessions = sessions
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        super.init()

        statusItem.autosaveName = "MidnightOilStatusItem"
        let menu = NSMenu()
        menu.delegate = self
        statusItem.menu = menu

        sessions.onChange = { [weak self] in self?.refreshButton() }
        refreshButton()
    }

    private func refreshButton() {
        let symbol = sessions.isActive ? "flame.fill" : "flame"
        let image = NSImage(systemSymbolName: symbol, accessibilityDescription: Brand.name)
        image?.isTemplate = true
        statusItem.button?.image = image
    }

    // MARK: - Menu

    func menuNeedsUpdate(_ menu: NSMenu) {
        menu.removeAllItems()

        if let session = sessions.session {
            menu.addItem(.sectionHeader(title: "Current Session"))
            let details = NSMenuItem(title: Self.describe(session), action: nil, keyEquivalent: "")
            details.isEnabled = false
            menu.addItem(details)

            let displaySleep = ClosureMenuItem("Allow Display Sleep") { [weak self] in
                self?.sessions.setAllowsDisplaySleep(!session.allowsDisplaySleep)
            }
            displaySleep.state = session.allowsDisplaySleep ? .on : .off
            menu.addItem(displaySleep)

            menu.addItem(ClosureMenuItem("End Session") { [weak self] in self?.sessions.end() })
            menu.addItem(.separator())
        }

        menu.addItem(.sectionHeader(title: "Start New Session"))
        menu.addItem(startItem("Indefinitely", end: .indefinite))
        menu.addItem(submenuItem("Minutes", items: Self.minuteChoices.map {
            startItem("\($0) minutes", end: .after(TimeInterval($0 * 60)))
        }))
        menu.addItem(submenuItem("Hours", items: Self.hourChoices.map {
            startItem($0 == 1 ? "1 hour" : "\($0) hours", end: .after(TimeInterval($0 * 3_600)))
        }))
        menu.addItem(submenuItem("Until", items: untilItems()))

        menu.addItem(.separator())
        menu.addItem(ClosureMenuItem("Quit \(Brand.name)", keyEquivalent: "q") {
            NSApp.terminate(nil)
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

    private func startItem(_ title: String, end: SessionEnd) -> NSMenuItem {
        ClosureMenuItem(title) { [weak self] in self?.sessions.start(end) }
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
        return "Ends in \(RemainingTime.short(remaining)) (\(clockTime(endDate)))"
    }

    /// "5:00 PM" today, "Wed 1:00 AM" on another day.
    private static func clockTime(_ date: Date) -> String {
        date.formatted(Calendar.current.isDateInToday(date)
            ? .dateTime.hour().minute()
            : .dateTime.weekday(.abbreviated).hour().minute())
    }
}
