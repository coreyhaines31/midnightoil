@testable import MidnightOilCore
import Testing

struct LidAlarmTests {
    @Test func soundsWhenTheLidClosesOnBattery() {
        #expect(LidAlarm.shouldSound(wasClosed: false, isClosed: true, isOnBattery: true))
    }

    @Test func staysQuietWhenPluggedIn() {
        #expect(!LidAlarm.shouldSound(wasClosed: false, isClosed: true, isOnBattery: false))
    }

    @Test func soundsOnlyOnTheClosingMoment() {
        #expect(!LidAlarm.shouldSound(wasClosed: true, isClosed: true, isOnBattery: true))
        #expect(!LidAlarm.shouldSound(wasClosed: true, isClosed: false, isOnBattery: true))
    }

    @Test func needsAPreviousReading() {
        #expect(!LidAlarm.shouldSound(wasClosed: nil, isClosed: true, isOnBattery: true))
    }
}
