/// Mirrors ProcessInfo.ThermalState so the rule can be tested without the system.
public enum ThermalLevel: Int, Comparable, Sendable {
    case nominal, fair, serious, critical

    public static func < (lhs: Self, rhs: Self) -> Bool { lhs.rawValue < rhs.rawValue }
}

/// A closed MacBook in a bag can't shed heat. When it gets hot, closed-lid mode steps aside so
/// macOS can sleep and cool it, then comes back once it has cooled.
public enum ThermalGuard {
    public static func shouldPause(wasPaused: Bool, level: ThermalLevel, isLidClosed: Bool) -> Bool {
        // Stay paused until the Mac is properly cool, so it doesn't flap at the threshold.
        if wasPaused { return level > .fair }
        // With the lid open someone is there, and macOS manages heat as usual.
        return isLidClosed && level >= .serious
    }
}
