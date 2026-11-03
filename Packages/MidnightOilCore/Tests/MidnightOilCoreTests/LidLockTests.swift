@testable import MidnightOilCore
import Testing

struct LidLockTests {
    @Test func unattendedOnlyWhenClosedAndUndocked() {
        #expect(LidLock.isUnattended(isClosed: true, hasExternalDisplay: false))
        #expect(!LidLock.isUnattended(isClosed: true, hasExternalDisplay: true))
        #expect(!LidLock.isUnattended(isClosed: false, hasExternalDisplay: false))
    }

    @Test func locksWhenTheMacBecomesUnattended() {
        #expect(LidLock.shouldLock(wasUnattended: false, isUnattended: true))
    }

    @Test func locksOnlyOnTheChange() {
        #expect(!LidLock.shouldLock(wasUnattended: true, isUnattended: true))
        #expect(!LidLock.shouldLock(wasUnattended: true, isUnattended: false))
        #expect(!LidLock.shouldLock(wasUnattended: false, isUnattended: false))
    }

    @Test func locksAMacThatIsAlreadyUnattendedOnTheFirstReading() {
        #expect(LidLock.shouldLock(wasUnattended: nil, isUnattended: true))
        #expect(!LidLock.shouldLock(wasUnattended: nil, isUnattended: false))
    }
}
