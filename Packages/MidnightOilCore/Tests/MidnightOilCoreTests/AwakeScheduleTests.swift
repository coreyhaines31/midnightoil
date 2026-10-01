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

    @Test func extraConditionsMustAlsoHold() {
        var schedule = AwakeSchedule.workHours
        schedule.conditions = [.powerSource(.powerAdapter)]
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "America/Los_Angeles") ?? .current
        // Tuesday 10 AM, inside work hours.
        let tuesday = calendar.date(from: DateComponents(year: 2026, month: 9, day: 29, hour: 10)) ?? .distantPast
        let power = PowerState(batteryPercent: 80, isOnBattery: false)
        let plugged = SystemState(power: power, date: tuesday, calendar: calendar)
        var onBattery = plugged
        onBattery.power = PowerState(batteryPercent: 80, isOnBattery: true)
        #expect(schedule.asTrigger.matches(plugged))
        #expect(!schedule.asTrigger.matches(onBattery))
    }

    @Test func roundTripsThroughJSON() throws {
        var plugged = AwakeSchedule.workHours
        plugged.conditions = [.powerSource(.powerAdapter)]
        let schedules = [plugged, AwakeSchedule.overnight]
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
