import Foundation

/// UserDefaults keys and typed accessors. SwiftUI settings views bind to the
/// same keys with `@AppStorage`.
enum Preferences {
    enum Key {
        static let allowsDisplaySleep = "allowsDisplaySleep"
        static let batteryFloorEnabled = "batteryFloorEnabled"
        static let batteryFloorPercent = "batteryFloorPercent"
        static let endsWhenUnplugged = "endsWhenUnplugged"
        static let showsRemainingInMenuBar = "showsRemainingInMenuBar"
        static let notifiesOnSessionEnd = "notifiesOnSessionEnd"
    }

    static let defaultBatteryFloorPercent = 20

    private static var defaults: UserDefaults { .standard }

    static func registerDefaults() {
        defaults.register(defaults: [
            Key.allowsDisplaySleep: false,
            Key.batteryFloorEnabled: false,
            Key.batteryFloorPercent: defaultBatteryFloorPercent,
            Key.endsWhenUnplugged: false,
            Key.showsRemainingInMenuBar: false,
            Key.notifiesOnSessionEnd: true
        ])
    }

    static var allowsDisplaySleep: Bool { defaults.bool(forKey: Key.allowsDisplaySleep) }

    static var batteryFloorPercent: Int? {
        defaults.bool(forKey: Key.batteryFloorEnabled) ? defaults.integer(forKey: Key.batteryFloorPercent) : nil
    }

    static var endsWhenUnplugged: Bool { defaults.bool(forKey: Key.endsWhenUnplugged) }

    static var showsRemainingInMenuBar: Bool { defaults.bool(forKey: Key.showsRemainingInMenuBar) }

    static var notifiesOnSessionEnd: Bool { defaults.bool(forKey: Key.notifiesOnSessionEnd) }
}
