import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let sessions = SessionController(helper: HelperClient())
    private let triggerStore = TriggerStore()
    private var triggerController: TriggerController?
    private var statusItemController: StatusItemController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        Preferences.registerDefaults()
        statusItemController = StatusItemController(sessions: sessions)
        triggerController = TriggerController(store: triggerStore, sessions: sessions)
    }

    func applicationWillTerminate(_ notification: Notification) {
        sessions.end()
    }
}
