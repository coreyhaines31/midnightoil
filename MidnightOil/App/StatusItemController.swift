import AppKit
import MidnightOilCore
import SwiftUI

/// Owns the menu bar icon. It stays a plain `NSStatusItem` with an `autosaveName`
/// (no custom view, never recreated) so macOS can Cmd-drag it and remember its position.
@MainActor
final class StatusItemController: NSObject, NSMenuDelegate {
    private static let minuteChoices = [5, 10, 15, 30, 45]
    private static let hourChoices = [1, 2, 3, 4, 6, 8, 12]
    private static let extendChoices = [5, 15, 30, 60, 120]

    private let statusItem: NSStatusItem
    private let sessions: SessionController
    private let updater: Updater
    private let customEndWindow = CustomEndWindow()
    private let settingsWindow: SettingsWindow
    private let schedules: ScheduleStore
    private let card = SessionCardModel()

    init(
        sessions: SessionController,
        triggers: TriggerStore,
        schedules: ScheduleStore,
        teams: TeamsLicense,
        updater: Updater
    ) {
        self.sessions = sessions
        self.updater = updater
        self.schedules = schedules
        settingsWindow = SettingsWindow(
            helper: sessions.helper,
            triggers: triggers,
            schedules: schedules,
            teams: teams,
            history: sessions.history,
            updater: updater
        )
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        super.init()

        statusItem.autosaveName = "MidnightOilStatusItem"
        let menu = NSMenu()
        menu.delegate = self
        statusItem.menu = menu

        statusItem.button?.imagePosition = .imageLeading
        sessions.onChange = { [weak self] in self?.refreshButton() }
        HotKeys.install(sessions: sessions) { [weak self] in self?.settingsWindow.show() }
        NotificationCenter.default.addObserver(
            forName: UserDefaults.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                StatusIcon.invalidateCache()
                self?.refreshButton()
            }
        }
        refreshButton()
    }

    private func refreshButton() {
        let image = StatusIcon.image(for: sessions.isActive ? .active : .inactive)
        image?.accessibilityDescription = Brand.name
        statusItem.button?.image = image

        var title = ""
        if Preferences.showsRemainingInMenuBar, let remaining = sessions.session?.remaining(at: .now) {
            title = " " + RemainingTime.short(remaining)
        }
        if statusItem.button?.title != title {
            statusItem.button?.title = title
        }
        if let session = sessions.session {
            card.update(from: session, schedules: schedules.schedules, policy: sessions.policy())
        }
    }

    // MARK: - Menu

    func menuNeedsUpdate(_ menu: NSMenu) {
        menu.removeAllItems()

        if let session = sessions.session {
            addCurrentSessionItems(for: session, to: menu)
            menu.addItem(.separator())
        } else if let recap = LastSessionView.recap(from: sessions.history.records) {
            let view = NSHostingView(rootView: LastSessionView(record: recap))
            view.frame.size = view.fittingSize
            let item = NSMenuItem()
            item.view = view
            menu.addItem(item)
            menu.addItem(.separator())
        }

        if sessions.session == nil, let next = nextScheduleItem() {
            menu.addItem(next)
            menu.addItem(.separator())
        }
        menu.addItem(startItem("Keep Awake Indefinitely", end: .indefinite, keyEquivalent: "i")
            .withToolTip(Help.Menu.indefinitely))
        menu.addItem(submenuItem("Keep Awake For", items: durationItems()).withToolTip(Help.Menu.forDuration))
        menu.addItem(submenuItem("Keep Awake Until", items: untilItems()).withToolTip(Help.Menu.until))
        menu.addItem(submenuItem("While App Is Running", items: runningAppItems()).withToolTip(Help.Menu.whileApp))
        menu.addItem(ClosureMenuItem("While File Is Downloading…", keyEquivalent: "f") { [weak self] in
            DownloadPicker.choose { file in self?.sessions.start(.whileDownloading(file)) }
        }.withToolTip(Help.Menu.whileDownloading))

        menu.addItem(.separator())
        menu.addItem(ClosureMenuItem("Settings…", keyEquivalent: ",") { [weak self] in
            self?.settingsWindow.show()
        }.withToolTip(Help.Menu.settings))
        let check = ClosureMenuItem("Check for Updates…") { [weak self] in self?.updater.checkForUpdates() }
        check.isEnabled = updater.canCheck
        check.toolTip = Help.Menu.checkForUpdates
        menu.addItem(check)
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
        card.update(from: session, schedules: schedules.schedules, policy: sessions.policy())
        let cardView = SessionCardView(
            model: card,
            showsLidOption: LidState.hasLid && !sessions.policy().disallowsClosedLid,
            onAllowDisplaySleep: { [weak self] allowed in self?.sessions.setAllowsDisplaySleep(allowed) },
            onStayAwakeWithLidClosed: { [weak self] _ in
                guard let self, let session = sessions.session else { return }
                menu.cancelTracking()
                toggleLidClosedMode(for: session)
            }
        )
        let hostingView = NSHostingView(rootView: cardView)
        hostingView.frame.size = hostingView.fittingSize
        let cardItem = NSMenuItem()
        cardItem.view = hostingView
        menu.addItem(cardItem)

        if session.endDate != nil {
            menu.addItem(submenuItem("Extend Session", items: Self.extendChoices.map { minutes in
                ClosureMenuItem("+ " + Self.durationTitle(minutes: minutes)) { [weak self] in
                    self?.sessions.extend(by: TimeInterval(minutes * 60))
                }
            }).withToolTip(Help.Menu.extend))
        }
        if case .schedule(let id, _) = session.source {
            menu.addItem(ClosureMenuItem(skipTitle(for: id), keyEquivalent: "x") { [weak self] in
                self?.sessions.end()
            }.withToolTip(Help.Menu.skipSchedule))
        } else {
            menu.addItem(ClosureMenuItem("End Session", keyEquivalent: "x") { [weak self] in
                self?.sessions.end()
            }.withToolTip(Help.Menu.end))
        }
    }

    /// "Skip Until Wed 9:00 AM": when the schedule next opens after this window.
    private func skipTitle(for id: UUID) -> String {
        guard let schedule = schedules.schedules.first(where: { $0.id == id }),
              let end = SessionCardModel.windowEnd(of: id, in: schedules.schedules),
              let next = schedule.schedule.nextStart(after: end, calendar: .current)
        else { return "Skip This Window" }
        return "Skip Until \(SessionCardModel.upcomingTime(next))"
    }

    /// "Work hours is waiting: On power adapter" when a window is open but a condition
    /// isn't met, otherwise "Work hours starts Mon 9:00 AM" for the soonest schedule.
    private func nextScheduleItem() -> NSMenuItem? {
        let enabled = schedules.schedules.filter(\.isEnabled)
        let open = enabled.filter { !$0.conditions.isEmpty && $0.schedule.contains(.now, calendar: .current) }
        if !open.isEmpty {
            let state = SystemStateReader.current(needs: TriggerController.needs(for: open.map(\.asTrigger)))
            for schedule in open {
                guard let failed = schedule.conditions.first(where: { !$0.matches(state) }) else { continue }
                let title = "\(schedule.name) is waiting: \(failed.summary)"
                let item = NSMenuItem(title: title, action: nil, keyEquivalent: "")
                item.isEnabled = false
                return item.withToolTip(Help.Menu.scheduleWaiting)
            }
        }
        let upcoming = enabled
            .compactMap { schedule in
                schedule.schedule.nextStart(after: .now, calendar: .current).map { (schedule.name, $0) }
            }
            .min { $0.1 < $1.1 }
        guard let (name, start) = upcoming else { return nil }
        let title = "\(name) starts \(SessionCardModel.upcomingTime(start))"
        let item = NSMenuItem(title: title, action: nil, keyEquivalent: "")
        item.isEnabled = false
        return item.withToolTip(Help.Menu.nextSchedule)
    }

    private func durationItems() -> [NSMenuItem] {
        var items = Self.minuteChoices.map {
            startItem(Self.durationTitle(minutes: $0), end: .after(TimeInterval($0 * 60)))
        }
        items.append(.separator())
        items += Self.hourChoices.map {
            startItem(Self.durationTitle(minutes: $0 * 60), end: .after(TimeInterval($0 * 3_600)))
        }
        return items
    }

    private func toggleLidClosedMode(for session: Session) {
        if session.staysAwakeWithLidClosed || sessions.helper.status == .installed {
            sessions.setStaysAwakeWithLidClosed(!session.staysAwakeWithLidClosed)
            return
        }
        let alert = NSAlert()
        alert.messageText = "Install the Closed-Lid Helper?"
        alert.informativeText = """
            macOS sleeps a laptop when its lid closes, no matter what apps ask. \
            \(Brand.name) needs a small helper, approved once in System Settings › Login Items, \
            to turn that off during a session. Sleep is restored as soon as the session ends \
            or \(Brand.name) quits.
            """
        alert.addButton(withTitle: "Install Helper")
        alert.addButton(withTitle: "Cancel")
        NSApp.activate()
        if alert.runModal() == .alertFirstButtonReturn {
            sessions.helper.install()
        }
    }

    private func untilItems() -> [NSMenuItem] {
        var items = UntilTimes.upcomingHours(after: .now, count: 8).map { date in
            startItem(SessionCardModel.clockTime(date), end: .until(date))
        }
        items.append(.separator())
        items.append(ClosureMenuItem("Other Time…") { [weak self] in
            self?.customEndWindow.show { date in self?.sessions.start(.until(date)) }
        }.withToolTip(Help.Menu.otherTime))
        return items
    }

    private func runningAppItems() -> [NSMenuItem] {
        let apps = NSWorkspace.shared.runningApplications
            .filter { $0.activationPolicy == .regular && $0 != .current && $0.bundleIdentifier != nil }
            .sorted { ($0.localizedName ?? "").localizedStandardCompare($1.localizedName ?? "") == .orderedAscending }

        guard !apps.isEmpty else {
            let none = NSMenuItem(title: "No Apps Running", action: nil, keyEquivalent: "")
            none.isEnabled = false
            return [none]
        }
        return apps.compactMap { app in
            guard let bundleIdentifier = app.bundleIdentifier else { return nil }
            let name = app.localizedName ?? bundleIdentifier
            let watched = WatchedApp(bundleIdentifier: bundleIdentifier, name: name)
            let item = startItem(name, end: .whileAppRunning(watched))
            item.image = app.icon.map { icon in
                let image = icon.copy() as? NSImage ?? icon
                image.size = NSSize(width: 16, height: 16)
                return image
            }
            return item
        }
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
}

private extension NSMenuItem {
    func withToolTip(_ text: String) -> NSMenuItem {
        toolTip = text
        return self
    }
}
