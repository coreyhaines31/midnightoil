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

    @Test func extendingATimedSessionPushesItsEnd() {
        let session = Session(start: start, end: .after(600), allowsDisplaySleep: true)
        let extended = session.extended(by: 900)
        #expect(extended.endDate == start.addingTimeInterval(1_500))
        #expect(extended.allowsDisplaySleep)
    }

    @Test func extendingAnUntilSessionPushesItsEnd() {
        let target = start.addingTimeInterval(3_600)
        let session = Session(start: start, end: .until(target), allowsDisplaySleep: false)
        #expect(session.extended(by: 1_800).endDate == target.addingTimeInterval(1_800))
    }

    @Test func extendingAnIndefiniteSessionChangesNothing() {
        let session = Session(start: start, end: .indefinite, allowsDisplaySleep: false)
        #expect(session.extended(by: 600) == session)
    }

    @Test func eventBasedSessionsHaveNoEndTime() {
        let app = WatchedApp(bundleIdentifier: "com.apple.Safari", name: "Safari")
        let ends: [SessionEnd] = [.whileAppRunning(app), .whileDownloading(URL(filePath: "/tmp/file.part"))]
        for end in ends {
            let session = Session(start: start, end: end, allowsDisplaySleep: false)
            #expect(session.endDate == nil)
            #expect(!session.isFinished(at: start.addingTimeInterval(1_000_000)))
            #expect(session.extended(by: 600) == session)
        }
    }
}
