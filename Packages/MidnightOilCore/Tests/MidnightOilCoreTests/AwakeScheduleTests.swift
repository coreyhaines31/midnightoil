import Foundation
@testable import MidnightOilCore
import Testing

struct AwakeScheduleTests {
    @Test func runsAsATriggerWithOneScheduleCondition() {
        let schedule = AwakeSchedule.workHours
        let trigger = schedule.asTrigger
        #expect(trigger.id == schedule.id)
        #expect(trigger.name == "Work hours")
        #expect(trigger.criteria == [.schedule(schedule.schedule)])
    }

    @Test func aDisabledScheduleNeverFires() {
        var schedule = AwakeSchedule.workHours
        schedule.isEnabled = false
        #expect(!schedule.asTrigger.isEnabled)
    }

    @Test func roundTripsThroughJSON() throws {
        let schedules = [AwakeSchedule.workHours, AwakeSchedule.overnight]
        let decoded = try JSONDecoder().decode([AwakeSchedule].self, from: JSONEncoder().encode(schedules))
        #expect(decoded == schedules)
    }

    @Test func historyWrittenBeforeSchedulesStillLoads() throws {
        let json = #"[{"id":"0B4B5E2C-6B0A-4F0B-9E3E-0D1C2B3A4F5E","start":0,"end":60,"endCause":"you"}]"#
        let records = try JSONDecoder().decode([SessionRecord].self, from: Data(json.utf8))
        #expect(records.first?.scheduleName == nil)
        #expect(records.first?.endCause == .you)
    }
}
