import Foundation
@testable import MidnightOilCore
import Testing

struct SessionGaugeTests {
    let start = Date(timeIntervalSinceReferenceDate: 1_000_000)

    func gauge(_ end: SessionEnd, window: Bool = false, cutoff: Bool = false) -> SessionGauge {
        let session = Session(start: start, end: end, allowsDisplaySleep: false)
        return SessionGauge.pick(for: session, endsWithScheduleWindow: window, hasPolicyCutoff: cutoff)
    }

    @Test func indefiniteAndWhileModesTurnTheReels() {
        let app = WatchedApp(bundleIdentifier: "com.apple.TextEdit", name: "TextEdit")
        for end in [SessionEnd.indefinite, .whileAppRunning(app), .whileDownloading(URL(filePath: "/tmp/a.part"))] {
            #expect(gauge(end) == .reels)
        }
    }

    @Test func durationsCountDown() {
        #expect(gauge(.after(1_800)) == .countdown)
    }

    @Test func clockTimesUseTheDial() {
        #expect(gauge(.until(start.addingTimeInterval(3_600))) == .clock)
    }

    @Test func scheduleWindowsUseTheDial() {
        #expect(gauge(.indefinite, window: true) == .clock)
    }

    @Test func policyLimitsCountDown() {
        #expect(gauge(.indefinite, cutoff: true) == .countdown)
    }
}

// swiftlint:disable:next large_tuple
private let scaleCases: [(TimeInterval, String, [String])] = [
    (5 * 60, "MIN LEFT", ["0", "1", "2", "3", "4", "5"]),
    (15 * 60, "MIN LEFT", ["0", "5", "10", "15"]),
    (45 * 60, "MIN LEFT", ["0", "15", "30", "45"]),
    (60 * 60, "MIN LEFT", ["0", "15", "30", "45", "60"]),
    (2 * 3_600, "HRS LEFT", ["0", "0.5", "1", "1.5", "2"]),
    (6 * 3_600, "HRS LEFT", ["0", "2", "4", "6"]),
    (12 * 3_600, "HRS LEFT", ["0", "3", "6", "9", "12"]),
    (65 * 60, "MIN LEFT", ["0", "65"]),
    (24 * 3_600, "HRS LEFT", ["0", "6", "12", "18", "24"]),
    (36 * 3_600, "HRS LEFT", ["0", "12", "24", "36"]),
    (72 * 3_600, "HRS LEFT", ["0", "24", "48", "72"]),
    (90 * 3_600, "DAYS LEFT", ["0", "3.8"]),
    (4 * 86_400, "DAYS LEFT", ["0", "1", "2", "3", "4"]),
    (10 * 86_400, "DAYS LEFT", ["0", "2", "4", "6", "8", "10"]),
    (14 * 86_400, "DAYS LEFT", ["0", "7", "14"])
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
    #expect(ElapsedCounter(0) == ElapsedCounter(59))
    let short = ElapsedCounter(5_025)
    #expect(short.days == nil && short.hours == "01" && short.minutes == "23")
    let almostADay = ElapsedCounter(86_399)
    #expect(almostADay.days == nil && almostADay.hours == "23" && almostADay.minutes == "59")
}

@Test func elapsedCounterAddsDaysPastADay() {
    let ninety = ElapsedCounter(81 * 3_600 + 42 * 60)
    #expect(ninety.days == "3" && ninety.hours == "09" && ninety.minutes == "42")
    let tenDays = ElapsedCounter(10 * 86_400 + 5 * 60)
    #expect(tenDays.days == "10" && tenDays.hours == "00" && tenDays.minutes == "05")
    let forever = ElapsedCounter(500 * 86_400)
    #expect(forever.days == "99" && forever.hours == "23" && forever.minutes == "59")
}
