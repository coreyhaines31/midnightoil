import Foundation

/// UserDefaults keys and typed accessors. SwiftUI settings views bind to the
/// same keys with `@AppStorage`.
enum Preferences {
    enum Key {
        static let allowsDisplaySleep = "allowsDisplaySleep"
        static let startsSessionAtLaunch = "startsSessionAtLaunch"
        static let staysAwakeWithLidClosed = "staysAwakeWithLidClosed"
        static let soundsLidAlarm = "soundsLidAlarm"
        static let batteryFloorEnabled = "batteryFloorEnabled"
        static let batteryFloorPercent = "batteryFloorPercent"
        static let endsWhenUnplugged = "endsWhenUnplugged"
        static let showsRemainingInMenuBar = "showsRemainingInMenuBar"
        static let notifiesOnSessionEnd = "notifiesOnSessionEnd"
        static let notifiesOnTriggerStart = "notifiesOnTriggerStart"
        static let notificationSound = "notificationSound"
        static let lidAlarmSound = "lidAlarmSound"
        static let triggersEnabled = "triggersEnabled"
        static let driveAliveEnabled = "driveAliveEnabled"
        static let statusIconStyle = "statusIconStyle"
        static let customIconsAreTemplates = "customIconsAreTemplates"
        static let driveAliveInterval = "driveAliveInterval"
        static let driveAliveVolumes = "driveAliveVolumes"
    }

    static let defaultBatteryFloorPercent = 20
    static let defaultSound = "default"
    static let noSound = "none"
    static let defaultLidAlarmSound = "Sosumi"

    private static var defaults: UserDefaults { .standard }

    static func registerDefaults() {
        defaults.register(defaults: [
            Key.allowsDisplaySleep: false,
            Key.startsSessionAtLaunch: false,
            Key.staysAwakeWithLidClosed: false,
            Key.soundsLidAlarm: true,
            Key.batteryFloorEnabled: false,
            Key.batteryFloorPercent: defaultBatteryFloorPercent,
            Key.endsWhenUnplugged: false,
            Key.showsRemainingInMenuBar: false,
            Key.notifiesOnSessionEnd: true,
            Key.notifiesOnTriggerStart: false,
            Key.notificationSound: defaultSound,
            Key.lidAlarmSound: defaultLidAlarmSound,
            Key.triggersEnabled: true,
            Key.driveAliveEnabled: false,
            Key.statusIconStyle: StatusIcon.Style.lamp.rawValue,
            Key.customIconsAreTemplates: true,
            Key.driveAliveInterval: 10
        ])
    }

    static var allowsDisplaySleep: Bool { defaults.bool(forKey: Key.allowsDisplaySleep) }

    static var startsSessionAtLaunch: Bool { defaults.bool(forKey: Key.startsSessionAtLaunch) }

    static var staysAwakeWithLidClosed: Bool { defaults.bool(forKey: Key.staysAwakeWithLidClosed) }

    static var soundsLidAlarm: Bool { defaults.bool(forKey: Key.soundsLidAlarm) }

    static var batteryFloorPercent: Int? {
        defaults.bool(forKey: Key.batteryFloorEnabled) ? defaults.integer(forKey: Key.batteryFloorPercent) : nil
    }

    static var endsWhenUnplugged: Bool { defaults.bool(forKey: Key.endsWhenUnplugged) }

    static var showsRemainingInMenuBar: Bool { defaults.bool(forKey: Key.showsRemainingInMenuBar) }

    static var notifiesOnSessionEnd: Bool { defaults.bool(forKey: Key.notifiesOnSessionEnd) }

    static var notifiesOnTriggerStart: Bool { defaults.bool(forKey: Key.notifiesOnTriggerStart) }

    static var notificationSound: String { defaults.string(forKey: Key.notificationSound) ?? defaultSound }

    static var lidAlarmSound: String { defaults.string(forKey: Key.lidAlarmSound) ?? defaultLidAlarmSound }

    static var triggersEnabled: Bool { defaults.bool(forKey: Key.triggersEnabled) }

    static var statusIconStyle: StatusIcon.Style {
        StatusIcon.Style(rawValue: defaults.string(forKey: Key.statusIconStyle) ?? "") ?? .lamp
    }

    static var customIconsAreTemplates: Bool { defaults.bool(forKey: Key.customIconsAreTemplates) }

    static var driveAliveEnabled: Bool { defaults.bool(forKey: Key.driveAliveEnabled) }

    static var driveAliveInterval: Int { defaults.integer(forKey: Key.driveAliveInterval) }

    static var driveAliveVolumes: [DriveAliveVolume] {
        get {
            guard let data = defaults.data(forKey: Key.driveAliveVolumes) else { return [] }
            return (try? JSONDecoder().decode([DriveAliveVolume].self, from: data)) ?? []
        }
        set {
            defaults.set(try? JSONEncoder().encode(newValue), forKey: Key.driveAliveVolumes)
        }
    }
}
