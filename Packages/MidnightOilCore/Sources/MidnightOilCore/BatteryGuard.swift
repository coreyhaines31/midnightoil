public struct PowerState: Equatable, Sendable {
    /// Nil on Macs without a battery.
    public var batteryPercent: Int?
    public var isOnBattery: Bool

    public init(batteryPercent: Int?, isOnBattery: Bool) {
        self.batteryPercent = batteryPercent
        self.isOnBattery = isOnBattery
    }
}

public enum BatteryGuard {
    /// A session ends early only when running on battery below the floor.
    /// Plugged-in Macs and desktops are never cut off.
    public static func shouldEndSession(power: PowerState, floorPercent: Int?) -> Bool {
        guard let floorPercent, power.isOnBattery, let percent = power.batteryPercent else { return false }
        return percent < floorPercent
    }
}
