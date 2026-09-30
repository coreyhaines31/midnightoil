@testable import MidnightOilCore
import Testing

struct BatteryGuardTests {
    @Test func endsWhenOnBatteryBelowTheFloor() {
        let power = PowerState(batteryPercent: 19, isOnBattery: true)
        #expect(BatteryGuard.shouldEndSession(power: power, floorPercent: 20))
    }

    @Test func keepsGoingAtTheFloor() {
        let power = PowerState(batteryPercent: 20, isOnBattery: true)
        #expect(!BatteryGuard.shouldEndSession(power: power, floorPercent: 20))
    }

    @Test func ignoresLowBatteryWhilePluggedIn() {
        let power = PowerState(batteryPercent: 5, isOnBattery: false)
        #expect(!BatteryGuard.shouldEndSession(power: power, floorPercent: 20))
    }

    @Test func ignoresMacsWithoutABattery() {
        let power = PowerState(batteryPercent: nil, isOnBattery: false)
        #expect(!BatteryGuard.shouldEndSession(power: power, floorPercent: 20))
    }

    @Test func doesNothingWithoutAFloor() {
        let power = PowerState(batteryPercent: 1, isOnBattery: true)
        #expect(!BatteryGuard.shouldEndSession(power: power, floorPercent: nil))
    }
}
