@testable import MidnightOilCore
import Testing

struct LidLockTests {
    @Test func locksWhenTheLidCloses() {
        #expect(LidLock.shouldLock(wasClosed: false, isClosed: true, hasExternalDisplay: false))
    }

    @Test func leavesDesktopSetupsAlone() {
        #expect(!LidLock.shouldLock(wasClosed: false, isClosed: true, hasExternalDisplay: true))
    }

    @Test func locksOnlyOnTheClosingMoment() {
        #expect(!LidLock.shouldLock(wasClosed: true, isClosed: true, hasExternalDisplay: false))
        #expect(!LidLock.shouldLock(wasClosed: true, isClosed: false, hasExternalDisplay: false))
    }

    @Test func needsAPreviousReading() {
        #expect(!LidLock.shouldLock(wasClosed: nil, isClosed: true, hasExternalDisplay: false))
    }
}
