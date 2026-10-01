import MidnightOilCore
import UserNotifications

/// Tells the user when a session ended without them ending it.
enum SessionNotifier {
    /// Away this long and the notification becomes a recap of what happened.
    private static let recapThreshold: TimeInterval = 10 * 60

    static func sessionEnded(_ reason: SessionEndReason, record: SessionRecord) {
        guard Preferences.notifiesOnSessionEnd, let body = message(for: reason) else { return }
        if record.away >= recapThreshold {
            post(title: "While you were away", body: "\(record.headline). \(body)")
        } else {
            post(title: "Session ended", body: body)
        }
    }

    static func sessionStarted(byTrigger name: String) {
        guard Preferences.notifiesOnTriggerStart else { return }
        post(title: "Keeping your Mac awake", body: "The “\(name)” trigger started a session.")
    }

    static func sessionStarted(bySchedule name: String) {
        guard Preferences.notifiesOnTriggerStart else { return }
        post(title: "Keeping your Mac awake", body: "Your “\(name)” schedule started a session.")
    }

    private static func post(title: String, body: String) {
        Task {
            let center = UNUserNotificationCenter.current()
            guard (try? await center.requestAuthorization(options: [.alert, .sound])) == true else { return }

            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = sound()
            try? await center.add(UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil))
        }
    }

    private static func sound() -> UNNotificationSound? {
        switch Preferences.notificationSound {
        case Preferences.noSound: nil
        case Preferences.defaultSound: .default
        case let name: UNNotificationSound(named: UNNotificationSoundName(SystemSounds.fileName(name)))
        }
    }

    private static func message(for reason: SessionEndReason) -> String? {
        switch reason {
        case .user, .replaced, .quit: nil
        case .timeUp: "Your Mac can sleep normally again."
        case .appQuit(let name): "\(name) quit, so your Mac can sleep again."
        case .downloadFinished(let name): "“\(name)” finished downloading, so your Mac can sleep again."
        case .unplugged: "Your Mac was unplugged, so it can sleep again."
        case .triggerEnded(let name): "The “\(name)” trigger no longer applies, so your Mac can sleep again."
        case .scheduleEnded(let name): "Your “\(name)” schedule is over, so your Mac can sleep again."
        case .schedulePaused(let name, let condition):
            "Your “\(name)” schedule paused because “\(condition)” stopped holding. It picks up again when it does."
        case .lowBattery:
            "Your battery dropped below \(Preferences.batteryFloorPercent ?? 0)%, so your Mac can sleep again."
        }
    }
}
