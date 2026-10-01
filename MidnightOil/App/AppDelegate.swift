import AppKit
import MidnightOilTeams

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let sessions = SessionController(helper: HelperClient())
    private let updater = Updater()
    private let triggerStore = TriggerStore()
    private let scheduleStore = ScheduleStore()
    private let teamsLicense = TeamsLicense()
    private var triggerController: TriggerController?
    private var driveAlive: DriveAliveController?
    private var statusItemController: StatusItemController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        Preferences.registerDefaults()
        sessions.helper.refreshAfterUpdate()
        sessions.policy = { [teamsLicense] in
            TeamsPolicy.read(from: .standard, licensed: teamsLicense.unlocks(.policies))
        }
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

    func applicationWillTerminate(_ notification: Notification) {
        sessions.end(reason: .quit)
    }
}
