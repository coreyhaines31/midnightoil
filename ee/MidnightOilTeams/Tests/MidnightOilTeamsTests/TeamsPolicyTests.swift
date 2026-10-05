import Foundation
import MidnightOilCore
@testable import MidnightOilTeams
import Testing

struct TeamsPolicyTests {
    func defaults(_ values: [String: Any]) -> UserDefaults {
        let suite = "TeamsPolicyTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        for (key, value) in values { defaults.set(value, forKey: key) }
        return defaults
    }

    @Test func nothingAppliesWithoutALicense() {
        let values: [String: Any] = [TeamsPolicyKey.disallowClosedLid: true, TeamsPolicyKey.maxSessionHours: 8]
        #expect(TeamsPolicy.read(from: defaults(values), licensed: false) == .none)
    }

    @Test func readsEachPolicy() {
        let policy = TeamsPolicy.read(from: defaults([
            TeamsPolicyKey.disallowClosedLid: true,
            TeamsPolicyKey.maxSessionHours: 8,
            TeamsPolicyKey.minimumBatteryFloor: 25
        ]), licensed: true)
        #expect(policy.disallowsClosedLid)
        #expect(policy.maxManualSession == TimeInterval(8 * 3_600))
        #expect(policy.minimumBatteryFloor == 25)
    }

    @Test func outOfRangeValuesAreIgnored() {
        let policy = TeamsPolicy.read(from: defaults([
            TeamsPolicyKey.maxSessionHours: 0,
            TeamsPolicyKey.minimumBatteryFloor: 100
        ]), licensed: true)
        #expect(policy == .none)
    }
}
