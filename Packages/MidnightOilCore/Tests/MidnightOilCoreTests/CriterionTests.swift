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

    @Test func suppressedTriggerStaysQuietUntilItStopsMatching() {
        #expect(TriggerEngine.activeTrigger(in: [home], state: homeState, suppressed: home.id) == nil)
        #expect(!TriggerEngine.canRearm(home.id, triggers: [home], state: homeState))
        #expect(TriggerEngine.canRearm(home.id, triggers: [home], state: SystemState(wifiNetwork: "Cafe")))
        #expect(TriggerEngine.canRearm(nil, triggers: [home], state: homeState))
    }
}
