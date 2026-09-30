import Foundation

/// UserDefaults keys and typed accessors. SwiftUI settings views bind to the
/// same keys with `@AppStorage`.
enum Preferences {
    enum Key {
        static let allowsDisplaySleep = "allowsDisplaySleep"
        static let staysAwakeWithLidClosed = "staysAwakeWithLidClosed"
        static let soundsLidAlarm = "soundsLidAlarm"
        static let batteryFloorEnabled = "batteryFloorEnabled"
        static let batteryFloorPercent = "batteryFloorPercent"
        static let endsWhenUnplugged = "endsWhenUnplugged"
        static let showsRemainingInMenuBar = "showsRemainingInMenuBar"
        static let notifiesOnSessionEnd = "notifiesOnSessionEnd"
        static let triggersEnabled = "triggersEnabled"
    }

    static let defaultBatteryFloorPercent = 20

    private static var defaults: UserDefaults { .standard }

    static func registerDefaults() {
        defaults.register(defaults: [
            Key.allowsDisplaySleep: false,
            Key.staysAwakeWithLidClosed: false,
            Key.soundsLidAlarm: true,
            Key.batteryFloorEnabled: false,
            Key.batteryFloorPercent: defaultBatteryFloorPercent,
            Key.endsWhenUnplugged: false,
            Key.showsRemainingInMenuBar: false,
            Key.notifiesOnSessionEnd: true,
            Key.triggersEnabled: true
        ])
    }

    static var allowsDisplaySleep: Bool { defaults.bool(forKey: Key.allowsDisplaySleep) }

    static var staysAwakeWithLidClosed: Bool { defaults.bool(forKey: Key.staysAwakeWithLidClosed) }

    static var soundsLidAlarm: Bool { defaults.bool(forKey: Key.soundsLidAlarm) }

    static var batteryFloorPercent: Int? {
        defaults.bool(forKey: Key.batteryFloorEnabled) ? defaults.integer(forKey: Key.batteryFloorPercent) : nil
    }

    static var endsWhenUnplugged: Bool { defaults.bool(forKey: Key.endsWhenUnplugged) }

    static var showsRemainingInMenuBar: Bool { defaults.bool(forKey: Key.showsRemainingInMenuBar) }

    static var notifiesOnSessionEnd: Bool { defaults.bool(forKey: Key.notifiesOnSessionEnd) }

    static var triggersEnabled: Bool { defaults.bool(forKey: Key.triggersEnabled) }
}
