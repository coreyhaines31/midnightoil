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

    @Test func detectsUnplugging() {
        let pluggedIn = PowerState(batteryPercent: 80, isOnBattery: false)
        let onBattery = PowerState(batteryPercent: 80, isOnBattery: true)
        #expect(BatteryGuard.wasUnplugged(from: pluggedIn, to: onBattery))
        #expect(!BatteryGuard.wasUnplugged(from: onBattery, to: onBattery))
        #expect(!BatteryGuard.wasUnplugged(from: onBattery, to: pluggedIn))
        #expect(!BatteryGuard.wasUnplugged(from: nil, to: onBattery))
    }
}
