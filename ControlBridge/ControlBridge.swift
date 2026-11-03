import Foundation

/// What the app and its Control Center extension share. The extension is sandboxed, so it
/// can't reach the CLI socket; it asks the app with Darwin notifications instead, and reads the
/// session state the app writes to their shared app group.
enum ControlBridge {
    static let appGroup = "KPQU8X839X.app.midnightoil.MidnightOil"
    static let controlKind = "app.midnightoil.MidnightOil.SessionToggle"
    static let isAwakeKey = "isAwake"
    static let startNotification = "app.midnightoil.MidnightOil.control.start"
    static let stopNotification = "app.midnightoil.MidnightOil.control.stop"

    static var defaults: UserDefaults? { UserDefaults(suiteName: appGroup) }

    static func post(_ name: String) {
        CFNotificationCenterPostNotification(
            CFNotificationCenterGetDarwinNotifyCenter(),
            CFNotificationName(name as CFString),
            nil,
            nil,
            true
        )
    }
}
