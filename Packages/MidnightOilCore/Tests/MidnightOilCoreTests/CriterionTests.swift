import Foundation
@testable import MidnightOilCore
import Testing

struct CriterionTests {
    let state = SystemState(
        wifiNetwork: "Home",
        usbDevices: ["Elgato Camera", "Keychron K2"],
        bluetoothDevices: ["AirPods Pro"],
        externalDisplayCount: 1,
        power: PowerState(batteryPercent: 55, isOnBattery: true),
        runningApps: ["com.apple.Safari", "com.figma.Desktop"],
        frontmostApp: "com.figma.Desktop",
        ipAddresses: ["192.168.1.20", "10.0.0.5"],
        idleSeconds: 120
    )

    @Test func wifiMatchesAnyListedNetwork() {
        #expect(Criterion.wifiNetwork(["Office", "Home"]).matches(state))
        #expect(!Criterion.wifiNetwork(["Office"]).matches(state))
        var offline = state
        offline.wifiNetwork = nil
        #expect(!Criterion.wifiNetwork(["Home"]).matches(offline))
    }

    @Test func devicesMatchAnyListedName() {
        #expect(Criterion.usbDevice(["Keychron K2"]).matches(state))
        #expect(!Criterion.usbDevice(["Blue Yeti"]).matches(state))
        #expect(Criterion.bluetoothDevice(["AirPods Pro", "Magic Mouse"]).matches(state))
    }

    @Test func externalDisplay() {
        #expect(Criterion.externalDisplay(connected: true).matches(state))
        var laptopOnly = state
        laptopOnly.externalDisplayCount = 0
        #expect(Criterion.externalDisplay(connected: false).matches(laptopOnly))
    }

    @Test func powerAndBattery() {
        #expect(Criterion.powerSource(.battery).matches(state))
        #expect(!Criterion.powerSource(.powerAdapter).matches(state))
        #expect(Criterion.batteryLevel(.atLeast, percent: 50).matches(state))
        #expect(!Criterion.batteryLevel(.atLeast, percent: 60).matches(state))
        #expect(Criterion.batteryLevel(.atMost, percent: 55).matches(state))
        var desktop = state
        desktop.power = PowerState(batteryPercent: nil, isOnBattery: false)
        #expect(!Criterion.batteryLevel(.atMost, percent: 100).matches(desktop))
    }

    @Test func apps() {
        #expect(Criterion.appRunning(["com.apple.Safari"]).matches(state))
        #expect(!Criterion.appRunning(["com.apple.Mail"]).matches(state))
        #expect(Criterion.appFrontmost(["com.figma.Desktop"]).matches(state))
        #expect(!Criterion.appFrontmost(["com.apple.Safari"]).matches(state))
    }

    @Test func ipAddressPrefix() {
        #expect(Criterion.ipAddress(prefixes: ["192.168.1."]).matches(state))
        #expect(!Criterion.ipAddress(prefixes: ["192.168.2."]).matches(state))
    }

    @Test func idleTime() {
        #expect(Criterion.idle(.atMost, minutes: 5).matches(state))
        #expect(!Criterion.idle(.atLeast, minutes: 5).matches(state))
    }

    @Test func criteriaRoundTripThroughJSON() throws {
        let criteria: [Criterion] = [
            .wifiNetwork(["Home"]),
            .batteryLevel(.atLeast, percent: 20),
            .schedule(Schedule(days: [2, 3], startMinute: 540, endMinute: 1_020)),
            .idle(.atMost, minutes: 10)
        ]
        let data = try JSONEncoder().encode(criteria)
        #expect(try JSONDecoder().decode([Criterion].self, from: data) == criteria)
    }
}

struct ScheduleTests {
    var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "America/Los_Angeles") ?? .current
        return calendar
    }

    /// 2026-09-29 is a Tuesday (weekday 3).
    func tuesday(_ hour: Int, _ minute: Int = 0) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: 9, day: 29, hour: hour, minute: minute)) ?? .distantPast
    }

    func wednesday(_ hour: Int, _ minute: Int = 0) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: 9, day: 30, hour: hour, minute: minute)) ?? .distantPast
    }

    @Test func workHoursOnWeekdays() {
        let schedule = Schedule(days: [2, 3, 4, 5, 6], startMinute: 9 * 60, endMinute: 17 * 60)
        #expect(schedule.contains(tuesday(9), calendar: calendar))
        #expect(schedule.contains(tuesday(16, 59), calendar: calendar))
        #expect(!schedule.contains(tuesday(17), calendar: calendar))
        #expect(!schedule.contains(tuesday(8, 59), calendar: calendar))
        let saturday = calendar.date(from: DateComponents(year: 2026, month: 10, day: 3, hour: 12)) ?? .distantPast
        #expect(!schedule.contains(saturday, calendar: calendar))
    }

    @Test func overnightScheduleWrapsPastMidnight() {
        let schedule = Schedule(days: [3], startMinute: 22 * 60, endMinute: 2 * 60)
        #expect(schedule.contains(tuesday(23), calendar: calendar))
        #expect(schedule.contains(wednesday(1, 30), calendar: calendar))
        #expect(!schedule.contains(wednesday(2), calendar: calendar))
        #expect(!schedule.contains(wednesday(23), calendar: calendar))
    }

    @Test func windowEndIsTodaysCloseForADaytimeWindow() {
        let schedule = Schedule(days: [2, 3, 4, 5, 6], startMinute: 9 * 60, endMinute: 17 * 60)
        #expect(schedule.windowEnd(containing: tuesday(10, 15), calendar: calendar) == tuesday(17))
        #expect(schedule.windowEnd(containing: tuesday(18), calendar: calendar) == nil)
    }

    @Test func windowEndOfAnOvernightWindowIsTheNextMorning() {
        let schedule = Schedule(days: [3], startMinute: 22 * 60, endMinute: 2 * 60)
        #expect(schedule.windowEnd(containing: tuesday(23), calendar: calendar) == wednesday(2))
        #expect(schedule.windowEnd(containing: wednesday(1), calendar: calendar) == wednesday(2))
    }

    @Test func nextStartSkipsDaysOffAndTheCurrentWindow() {
        let workHours = Schedule(days: [2, 3, 4, 5, 6], startMinute: 9 * 60, endMinute: 17 * 60)
        #expect(workHours.nextStart(after: tuesday(8), calendar: calendar) == tuesday(9))
        #expect(workHours.nextStart(after: tuesday(9), calendar: calendar) == wednesday(9))
        let friday = calendar.date(from: DateComponents(year: 2026, month: 10, day: 2, hour: 17)) ?? .distantPast
        let monday = calendar.date(from: DateComponents(year: 2026, month: 10, day: 5, hour: 9)) ?? .distantPast
        #expect(workHours.nextStart(after: friday, calendar: calendar) == monday)
        // Sunday-only wraps around the week from a Tuesday.
        let sundays = Schedule(days: [1], startMinute: 0, endMinute: 60)
        let sunday = calendar.date(from: DateComponents(year: 2026, month: 10, day: 4)) ?? .distantPast
        #expect(sundays.nextStart(after: tuesday(12), calendar: calendar) == sunday)
        let noDays = Schedule(days: [], startMinute: 0, endMinute: 60)
        #expect(noDays.nextStart(after: tuesday(12), calendar: calendar) == nil)
    }

    @Test func daysSummaryReadsLikeAPerson() {
        var calendar = calendar
        calendar.locale = Locale(identifier: "en_US")
        func summary(_ days: Set<Int>) -> String {
            Schedule(days: days, startMinute: 0, endMinute: 60).daysSummary(calendar: calendar)
        }
        #expect(summary([1, 2, 3, 4, 5, 6, 7]) == "Every day")
        #expect(summary([2, 3, 4, 5, 6]) == "Weekdays")
        #expect(summary([1, 7]) == "Weekends")
        #expect(summary([2, 3, 4, 5]) == "Mon–Thu")
        #expect(summary([5, 6, 7, 1]) == "Thu–Sun")
        #expect(summary([2, 4, 6]) == "Mon, Wed, Fri")
        #expect(summary([2, 3]) == "Mon, Tue")
        #expect(summary([]) == "No days")
    }
}

struct TriggerEngineTests {
    let home = Trigger(name: "Home", criteria: [.wifiNetwork(["Home"])])
    let docked = Trigger(name: "Docked", criteria: [.externalDisplay(connected: true), .powerSource(.powerAdapter)])
    let homeState = SystemState(
        wifiNetwork: "Home",
        externalDisplayCount: 1,
        power: PowerState(batteryPercent: 90, isOnBattery: true)
    )

    @Test func allCriteriaMustHold() {
        #expect(!docked.matches(homeState))
        var plugged = homeState
        plugged.power = PowerState(batteryPercent: 90, isOnBattery: false)
        #expect(docked.matches(plugged))
    }

    @Test func disabledOrEmptyTriggersNeverFire() {
        var disabled = home
        disabled.isEnabled = false
        #expect(!disabled.matches(homeState))
        #expect(!Trigger(name: "Empty", criteria: []).matches(homeState))
    }

    @Test func firstMatchingTriggerWins() {
        let active = TriggerEngine.activeTrigger(in: [docked, home], state: homeState, suppressed: nil)
        #expect(active?.id == home.id)
    }

    @Test func theRunningTriggerKeepsGoingWhileItStillMatches() {
        let anywhere = Trigger(name: "Anywhere", criteria: [.powerSource(.battery)])
        let triggers = [anywhere, home]
        let kept = TriggerEngine.activeTrigger(in: triggers, state: homeState, suppressed: nil, running: home.id)
        #expect(kept?.id == home.id)
        let away = SystemState(wifiNetwork: "Cafe", power: PowerState(batteryPercent: 90, isOnBattery: true))
        let next = TriggerEngine.activeTrigger(in: triggers, state: away, suppressed: nil, running: home.id)
        #expect(next?.id == anywhere.id)
    }

    @Test func suppressedTriggerStaysQuietUntilItStopsMatching() {
        #expect(TriggerEngine.activeTrigger(in: [home], state: homeState, suppressed: home.id) == nil)
        #expect(!TriggerEngine.canRearm(home.id, triggers: [home], state: homeState))
        #expect(TriggerEngine.canRearm(home.id, triggers: [home], state: SystemState(wifiNetwork: "Cafe")))
        #expect(TriggerEngine.canRearm(nil, triggers: [home], state: homeState))
    }
}
