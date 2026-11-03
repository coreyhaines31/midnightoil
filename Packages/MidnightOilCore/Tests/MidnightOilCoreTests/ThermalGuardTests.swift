@testable import MidnightOilCore
import Testing

struct ThermalGuardTests {
    @Test func pausesWhenHotWithTheLidClosed() {
        #expect(ThermalGuard.shouldPause(wasPaused: false, level: .serious, isLidClosed: true))
        #expect(ThermalGuard.shouldPause(wasPaused: false, level: .critical, isLidClosed: true))
    }

    @Test func ignoresWarmMacs() {
        #expect(!ThermalGuard.shouldPause(wasPaused: false, level: .fair, isLidClosed: true))
        #expect(!ThermalGuard.shouldPause(wasPaused: false, level: .nominal, isLidClosed: true))
    }

    @Test func leavesAnOpenLidAlone() {
        #expect(!ThermalGuard.shouldPause(wasPaused: false, level: .critical, isLidClosed: false))
    }

    @Test func staysPausedUntilCool() {
        #expect(ThermalGuard.shouldPause(wasPaused: true, level: .serious, isLidClosed: false))
        #expect(!ThermalGuard.shouldPause(wasPaused: true, level: .fair, isLidClosed: true))
        #expect(!ThermalGuard.shouldPause(wasPaused: true, level: .nominal, isLidClosed: true))
    }
}
