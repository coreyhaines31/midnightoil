import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let sessions = SessionController(helper: HelperClient())
    private let triggerStore = TriggerStore()
    private var triggerController: TriggerController?
    private var driveAlive: DriveAliveController?
    private var statusItemController: StatusItemController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        Preferences.registerDefaults()
        statusItemController = StatusItemController(sessions: sessions, triggers: triggerStore)
        triggerController = TriggerController(store: triggerStore, sessions: sessions)
        driveAlive = DriveAliveController(sessions: sessions)
        if Preferences.startsSessionAtLaunch {
            sessions.start(.indefinite)
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        sessions.end()
    }
}
