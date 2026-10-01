import Foundation
import MidnightOilCore

/// The UserDefaults keys an organization sets in its configuration profile.
public enum TeamsPolicyKey {
    public static let disallowClosedLid = "policyDisallowClosedLid"
    public static let maxSessionHours = "policyMaxSessionHours"
    public static let minimumBatteryFloor = "policyMinimumBatteryFloor"

    public static let all = [disallowClosedLid, maxSessionHours, minimumBatteryFloor]
}

public enum TeamsPolicy {
    /// The policy in `defaults`, or none without a license that includes policies.
    /// Out-of-range values are ignored rather than trusted.
    public static func read(from defaults: UserDefaults, licensed: Bool) -> SessionPolicy {
        guard licensed else { return .none }
        let hours = defaults.object(forKey: TeamsPolicyKey.maxSessionHours) as? Int
        let floor = defaults.object(forKey: TeamsPolicyKey.minimumBatteryFloor) as? Int
        return SessionPolicy(
            disallowsClosedLid: defaults.bool(forKey: TeamsPolicyKey.disallowClosedLid),
            maxManualSession: hours.flatMap { (1...168).contains($0) ? TimeInterval($0) * 3_600 : nil },
            minimumBatteryFloor: floor.flatMap { (1...99).contains($0) ? $0 : nil }
        )
    }
}
