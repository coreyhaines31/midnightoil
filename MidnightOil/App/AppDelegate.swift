import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let sessions = SessionController()
    private var statusItemController: StatusItemController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        Preferences.registerDefaults()
        statusItemController = StatusItemController(sessions: sessions)
    }

    func applicationWillTerminate(_ notification: Notification) {
        sessions.end()
    }
}
