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
        let session = Session(start: start, end: .after(600), allowsDisplaySleep: true, staysAwakeWithLidClosed: true)
        let extended = session.extended(by: 900)
        #expect(extended.endDate == start.addingTimeInterval(1_500))
        #expect(extended.allowsDisplaySleep)
        #expect(extended.staysAwakeWithLidClosed)
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
        let ends: [SessionEnd] = [
            .whileAppRunning(app),
            .whileDownloading(URL(filePath: "/tmp/file.part")),
            .whileProcessesRunning([WatchedProcess(pid: 42, name: "claude")])
        ]
        for end in ends {
            let session = Session(start: start, end: end, allowsDisplaySleep: false)
            #expect(session.endDate == nil)
            #expect(!session.isFinished(at: start.addingTimeInterval(1_000_000)))
            #expect(session.extended(by: 600) == session)
        }
    }

    @Test func sessionsAreManualUnlessATriggerStartedThem() {
        let manual = Session(start: start, end: .indefinite, allowsDisplaySleep: false)
        #expect(manual.source == .manual)
        let id = UUID()
        let source = SessionSource.trigger(id: id, name: "Home")
        let auto = Session(start: start, end: .indefinite, allowsDisplaySleep: false, source: source)
        #expect(auto.source == .trigger(id: id, name: "Home"))
        #expect(auto.extended(by: 60).source == auto.source)
    }

    @Test func aProcessJoinsAProcessSessionOnce() {
        let first = WatchedProcess(pid: 1, name: "claude")
        let second = WatchedProcess(pid: 2, name: "codex")
        let session = Session(start: start, end: .whileProcessesRunning([first]), allowsDisplaySleep: false)
        let joined = session.joining(second).joining(second)
        #expect(joined.end == .whileProcessesRunning([first, second]))
        #expect(joined.start == start)
    }

    @Test func onlyProcessSessionsTakeProcesses() {
        let session = Session(start: start, end: .indefinite, allowsDisplaySleep: false)
        #expect(session.joining(WatchedProcess(pid: 1, name: "claude")) == session)
        #expect(session.keepingProcesses { _ in false } == session)
    }

    @Test func aProcessSessionLastsUntilEveryProcessExits() {
        let processes = [WatchedProcess(pid: 1, name: "claude"), WatchedProcess(pid: 2, name: "codex")]
        let session = Session(start: start, end: .whileProcessesRunning(processes), allowsDisplaySleep: false)
        let kept = session.keepingProcesses { $0 == 2 }
        #expect(kept?.end == .whileProcessesRunning([processes[1]]))
        #expect(session.keepingProcesses { _ in false } == nil)
    }
}
