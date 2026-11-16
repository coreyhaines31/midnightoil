import Foundation
@testable import MidnightOilCore
import Testing

struct SessionGaugeTests {
    let start = Date(timeIntervalSinceReferenceDate: 1_000_000)

    func session(_ end: SessionEnd) -> Session {
        Session(start: start, end: end, allowsDisplaySleep: false)
    }

    @Test func indefiniteAndWhileModesTurnTheReels() {
        let app = WatchedApp(bundleIdentifier: "com.apple.TextEdit", name: "TextEdit")
        for end in [SessionEnd.indefinite, .whileAppRunning(app), .whileDownloading(URL(filePath: "/tmp/a.part"))] {
            #expect(SessionGauge.pick(for: session(end), endsWithScheduleWindow: false, hasPolicyCutoff: false) == .reels)
        }
    }

    @Test func durationsCountDown() {
        #expect(SessionGauge.pick(for: session(.after(1_800)), endsWithScheduleWindow: false, hasPolicyCutoff: false) == .countdown)
    }

    @Test func clockTimesUseTheDial() {
        let until = session(.until(start.addingTimeInterval(3_600)))
        #expect(SessionGauge.pick(for: until, endsWithScheduleWindow: false, hasPolicyCutoff: false) == .clock)
    }

    @Test func scheduleWindowsUseTheDial() {
        #expect(SessionGauge.pick(for: session(.indefinite), endsWithScheduleWindow: true, hasPolicyCutoff: false) == .clock)
    }

    @Test func policyLimitsCountDown() {
        #expect(SessionGauge.pick(for: session(.indefinite), endsWithScheduleWindow: false, hasPolicyCutoff: true) == .countdown)
    }
}

private let scaleCases: [(TimeInterval, String, [String])] = [
    (5 * 60, "MIN LEFT", ["0", "1", "2", "3", "4", "5"]),
    (15 * 60, "MIN LEFT", ["0", "5", "10", "15"]),
    (45 * 60, "MIN LEFT", ["0", "15", "30", "45"]),
    (60 * 60, "MIN LEFT", ["0", "15", "30", "45", "60"]),
    (2 * 3_600, "HRS LEFT", ["0", "0.5", "1", "1.5", "2"]),
    (6 * 3_600, "HRS LEFT", ["0", "2", "4", "6"]),
    (12 * 3_600, "HRS LEFT", ["0", "3", "6", "9", "12"]),
    (65 * 60, "MIN LEFT", ["0", "65"])
]

@Test(arguments: scaleCases)
func countdownScaleSplitsEvenly(total: TimeInterval, word: String, labels: [String]) {
    let scale = CountdownScale(total: total)
    #expect(scale.word == word)
    #expect(scale.labels.map(\.text) == labels)
    #expect(scale.labels.first?.position == 0)
    #expect(scale.labels.last?.position == 1)
}

@Test func needleRunsFromFullToZero() {
    #expect(CountdownScale.needle(remaining: 1_800, total: 1_800) == 1)
    #expect(CountdownScale.needle(remaining: 450, total: 1_800) == 0.25)
    #expect(CountdownScale.needle(remaining: -5, total: 1_800) == 0)
    #expect(CountdownScale.needle(remaining: 10, total: 0) == 0)
}

@Test func elapsedCounterShowsHoursAndMinutes() {
    #expect(ElapsedCounter.digits(0) == ("00", "00"))
    #expect(ElapsedCounter.digits(59) == ("00", "00"))
    #expect(ElapsedCounter.digits(5_025) == ("01", "23"))
    #expect(ElapsedCounter.digits(500 * 3_600) == ("99", "59"))
}
