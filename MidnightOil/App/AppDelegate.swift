import AppKit
import MidnightOilTeams

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let sessions = SessionController(helper: HelperClient())
    private let updater = Updater()
    private let triggerStore = TriggerStore()
    private let scheduleStore = ScheduleStore()
    private let teamsLicense = TeamsLicense()
    private lazy var webhook = SessionWebhookSender(license: teamsLicense)
    private lazy var fleet = FleetReporter(license: teamsLicense, sessions: sessions)
    private var triggerController: TriggerController?
    private var driveAlive: DriveAliveController?
    private var statusItemController: StatusItemController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        Preferences.registerDefaults()
        sessions.helper.refreshAfterUpdate()
        sessions.policy = { [teamsLicense] in
            TeamsPolicy.read(from: .standard, licensed: teamsLicense.unlocks(.policies))
        }
        sessions.onSessionEvent = { [weak self] event in
            self?.webhook.send(event)
            self?.fleet.report(event)
        }
        fleet.start()
        statusItemController = StatusItemController(
            sessions: sessions,
            triggers: triggerStore,
            schedules: scheduleStore,
            teams: teamsLicense,
            updater: updater
        )
        triggerController = TriggerController(store: triggerStore, schedules: scheduleStore, sessions: sessions)
        driveAlive = DriveAliveController(sessions: sessions)
        if Preferences.startsSessionAtLaunch {
            sessions.start(.indefinite)
        }
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        // End the session now so its webhook event can go out, then give it a moment.
        sessions.end(reason: .quit)
        Task {
            async let webhookDone: Void = webhook.waitForDeliveries(timeout: .seconds(3))
            async let fleetDone: Void = fleet.waitForReports(timeout: .seconds(3))
            _ = await (webhookDone, fleetDone)
            sender.reply(toApplicationShouldTerminate: true)
        }
        return .terminateLater
    }

    func applicationWillTerminate(_ notification: Notification) {
        sessions.end(reason: .quit)
    }
}
