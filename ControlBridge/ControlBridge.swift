import Foundation

/// What the app and its Control Center extension share. The extension is sandboxed, so it
/// can't reach the CLI socket. It writes its request to the app group, which only this user can
/// write to, and posts a Darwin notification to wake the app. Darwin notifications reach every
/// user's processes, so the notification carries nothing: the app acts only on a new request.
enum ControlBridge {
    static let appGroup = "KPQU8X839X.app.midnightoil.MidnightOil"
    static let appBundleIdentifier = "app.midnightoil.MidnightOil"
    static let controlKind = "app.midnightoil.MidnightOil.SessionToggle"
    static let requestNotification = "app.midnightoil.MidnightOil.control.request"

    private static let isAwakeKey = "isAwake"
    /// "<uuid> 1" or "<uuid> 0", in one value so the ID and the choice can't be read half-written.
    private static let requestKey = "request"

    static var defaults: UserDefaults? { UserDefaults(suiteName: appGroup) }

    /// Whether a session was running when the app last said so.
    static var publishedIsAwake: Bool { defaults?.bool(forKey: isAwakeKey) ?? false }

    static func publish(isAwake: Bool) {
        defaults?.set(isAwake, forKey: isAwakeKey)
    }

    /// From the extension: ask the app to start or end a session.
    static func request(awake: Bool) {
        defaults?.set("\(UUID().uuidString) \(awake ? 1 : 0)", forKey: requestKey)
        CFNotificationCenterPostNotification(
            CFNotificationCenterGetDarwinNotifyCenter(),
            CFNotificationName(requestNotification as CFString),
            nil,
            nil,
            true
        )
    }

    /// The latest request, with an ID so the app can tell new requests from stray notifications.
    static var latestRequest: (id: String, awake: Bool)? {
        guard let parts = defaults?.string(forKey: requestKey)?.split(separator: " "), parts.count == 2 else {
            return nil
        }
        return (String(parts[0]), parts[1] == "1")
    }
}
