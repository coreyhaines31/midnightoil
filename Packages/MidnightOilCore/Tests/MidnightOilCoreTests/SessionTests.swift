import Foundation
@testable import MidnightOilCore
import Testing

struct SessionTests {
    let start = Date(timeIntervalSinceReferenceDate: 1_000_000)

    @Test func indefiniteSessionNeverFinishes() {
        let session = Session(start: start, end: .indefinite, allowsDisplaySleep: false)
        #expect(session.endDate == nil)
        #expect(session.remaining(at: start.addingTimeInterval(1_000_000)) == nil)
        #expect(!session.isFinished(at: start.addingTimeInterval(1_000_000)))
    }

    @Test func timedSessionCountsDownAndFinishes() {
        let session = Session(start: start, end: .after(600), allowsDisplaySleep: false)
        #expect(session.remaining(at: start.addingTimeInterval(200)) == 400)
        #expect(!session.isFinished(at: start.addingTimeInterval(599)))
        #expect(session.isFinished(at: start.addingTimeInterval(600)))
    }

    @Test func remainingNeverGoesNegative() {
        let session = Session(start: start, end: .after(60), allowsDisplaySleep: false)
        #expect(session.remaining(at: start.addingTimeInterval(3_600)) == 0)
    }

    @Test func untilSessionEndsAtTheGivenDate() {
        let target = start.addingTimeInterval(7_200)
        let session = Session(start: start, end: .until(target), allowsDisplaySleep: true)
        #expect(session.endDate == target)
    }
}
