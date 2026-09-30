/// Amphetamine-style reminder: when a Mac that's being kept awake with its lid
/// shut gets closed on battery, sound an alarm so it doesn't cook in a bag.
public enum LidAlarm {
    public static func shouldSound(wasClosed: Bool?, isClosed: Bool, isOnBattery: Bool) -> Bool {
        guard let wasClosed else { return false }
        return !wasClosed && isClosed && isOnBattery
    }
}
