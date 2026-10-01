import Foundation
@testable import MidnightOilCore
import Testing

struct SessionPolicyTests {
    @Test func noPolicyChangesNothing() {
        #expect(SessionPolicy.none.batteryFloor(user: nil) == nil)
        #expect(SessionPolicy.none.batteryFloor(user: 15) == 15)
        let session = Session(start: .distantPast, end: .indefinite, allowsDisplaySleep: false)
        #expect(!SessionPolicy.none.isOverLimit(session, at: .now))
    }

    @Test func theStricterBatteryFloorWins() {
        let policy = SessionPolicy(minimumBatteryFloor: 20)
        #expect(policy.batteryFloor(user: nil) == 20)
        #expect(policy.batteryFloor(user: 10) == 20)
        #expect(policy.batteryFloor(user: 35) == 35)
    }

    @Test func theLimitAppliesOnlyToManualSessions() {
        let start = Date(timeIntervalSince1970: 1_000_000)
        let policy = SessionPolicy(maxManualSession: 8 * 3_600)
        let manual = Session(start: start, end: .indefinite, allowsDisplaySleep: false)
        #expect(!policy.isOverLimit(manual, at: start.addingTimeInterval(8 * 3_600 - 1)))
        #expect(policy.isOverLimit(manual, at: start.addingTimeInterval(8 * 3_600)))
        let scheduled = Session(
            start: start, end: .indefinite, allowsDisplaySleep: false,
            source: .schedule(id: UUID(), name: "Overnight")
        )
        #expect(!policy.isOverLimit(scheduled, at: start.addingTimeInterval(24 * 3_600)))
    }
}
