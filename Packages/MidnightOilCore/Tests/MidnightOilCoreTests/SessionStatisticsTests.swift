import Foundation
@testable import MidnightOilCore
import Testing

struct SessionStatisticsTests {
    var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "America/Los_Angeles") ?? .current
        return calendar
    }

    func date(_ day: Int, _ hour: Int, _ minute: Int = 0) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: 9, day: day, hour: hour, minute: minute)) ?? .distantPast
    }

    @Test func summarizesTotalsLongestAndThisWeek() {
        // 2026-09-29 is a Tuesday; the week starts Sunday 09-27.
        let records = [
            SessionRecord(start: date(20, 9), end: date(20, 11)),                       // last week, 2h
            SessionRecord(start: date(28, 9), end: date(28, 12), triggerName: "Home"),  // this week, 3h
            SessionRecord(start: date(29, 14), end: date(29, 15))                       // this week, 1h
        ]
        let stats = SessionStatistics.summarize(records, now: date(29, 16), calendar: calendar)
        #expect(stats.sessionCount == 3)
        #expect(stats.totalAwake == 6 * 3_600)
        #expect(stats.longest == 3 * 3_600)
        #expect(stats.awakeThisWeek == 4 * 3_600)
        #expect(stats.triggeredCount == 1)
    }

    @Test func emptyHistoryIsAllZeros() {
        #expect(SessionStatistics.summarize([], now: date(29, 16), calendar: calendar) == SessionStatistics())
    }

    @Test func durationNeverGoesNegative() {
        #expect(SessionRecord(start: date(29, 15), end: date(29, 14)).duration == 0)
    }

    @Test func measuredTimeWinsOverWallClock() {
        // Eight hours on the clock, but the Mac slept for two of them.
        let record = SessionRecord(start: date(28, 23), end: date(29, 7), awakeTime: 6 * 3_600, awayTime: 5 * 3_600)
        let stats = SessionStatistics.summarize([record], now: date(29, 8), calendar: calendar)
        #expect(stats.totalAwake == 6 * 3_600)
        #expect(stats.totalAway == 5 * 3_600)
        #expect(stats.awayThisWeek == 5 * 3_600)
    }

    @Test func awayNeverExceedsAwake() {
        let record = SessionRecord(start: date(29, 1), end: date(29, 2), awakeTime: 600, awayTime: 900)
        #expect(record.away == 600)
    }

    @Test func headlineMentionsAwayTimeOnlyWhenThereIsSome() {
        let atDesk = SessionRecord(start: date(29, 9), end: date(29, 10), awakeTime: 3_600, awayTime: 0)
        #expect(atDesk.headline == "1h awake")
        let overnight = SessionRecord(start: date(28, 23), end: date(29, 7), awakeTime: 28_080, awayTime: 24_900)
        #expect(overnight.headline == "7h 48m awake, 6h 55m while you were away")
    }

    @Test func unknownEndCausesDecodeInsteadOfFailing() throws {
        let json = #"[{"id":"895A3519-B96C-4B1C-A50C-61BC9863C7B8","start":1,"end":2,"endCause":"futureCause"}]"#
        let records = try JSONDecoder().decode([SessionRecord].self, from: Data(json.utf8))
        #expect(records[0].endCause == .unknown)
    }

    @Test func olderRecordsWithoutNewFieldsStillDecode() throws {
        let json = #"[{"id":"895A3519-B96C-4B1C-A50C-61BC9863C7B8","start":812427885.9,"end":812427891.9}]"#
        let records = try JSONDecoder().decode([SessionRecord].self, from: Data(json.utf8))
        #expect(records.count == 1)
        #expect(records[0].endCause == nil)
        #expect(records[0].away == 0)
    }
}

struct SessionTallyTests {
    let start = Date(timeIntervalSinceReferenceDate: 1_000_000)

    /// Samples every second from `from` to `to`, with idle time supplied per second.
    func run(_ tally: inout SessionTally, from first: Int, to last: Int, idle: (Int) -> TimeInterval) {
        for second in first...last {
            let now = start.addingTimeInterval(TimeInterval(second))
            tally.sample(at: now, idleSeconds: idle(second), lidClosed: false, lidMode: false)
        }
    }

    @Test func sleepIsNeverCreditedAsAwayTime() {
        // Codex repro: 600s active, 30s idle, a 240s sleep, then 30s more idle.
        // The system idle clock keeps running through the sleep; only 60 awake seconds were idle.
        var tally = SessionTally(start: start)
        run(&tally, from: 1, to: 600, idle: { _ in 0 })
        run(&tally, from: 601, to: 630, idle: { TimeInterval($0 - 600) })
        run(&tally, from: 871, to: 900, idle: { TimeInterval($0 - 600) })
        #expect(tally.awake == 659)  // the sample that ends the sleep gap is dropped too
        // Away starts once idle reaches 5 minutes (at t=900); only awake idle seconds count.
        #expect(tally.away <= 60)
    }

    @Test func shortSleepIsExcludedAfterResume() {
        var tally = SessionTally(start: start)
        tally.sample(at: start.addingTimeInterval(1), idleSeconds: 0, lidClosed: false, lidMode: false)
        // Sleeps at t=1, wakes at t=21: under maxGap, so only the explicit resume excludes it.
        tally.resumeAfterSleep(at: start.addingTimeInterval(21))
        tally.sample(at: start.addingTimeInterval(21), idleSeconds: 0, lidClosed: false, lidMode: false)
        #expect(tally.awake == 1)
    }

    @Test func awayStartsCountingOnceYouCrossTheThresholdWhileAwake() {
        var tally = SessionTally(start: start)
        // Idle the whole time, awake the whole time: after 10 minutes, all 10 were away.
        run(&tally, from: 1, to: 600, idle: { TimeInterval($0) })
        #expect(tally.away == 600)
    }

    @Test func inputResetsTheIdleStreak() {
        var tally = SessionTally(start: start)
        // Idle for 4 minutes, a keypress at t=240, then idle for 6 minutes.
        run(&tally, from: 1, to: 600, idle: { $0 < 240 ? TimeInterval($0) : TimeInterval($0 - 240) })
        // Away from t=240 onward (360s), not from t=0.
        #expect(abs(tally.away - 360) <= 1)
    }

    @Test func countsAwakeTimeFromSamples() {
        var tally = SessionTally(start: start)
        for second in 1...10 {
            let now = start.addingTimeInterval(TimeInterval(second))
            tally.sample(at: now, idleSeconds: 0, lidClosed: false, lidMode: false)
        }
        #expect(tally.awake == 10)
        #expect(tally.away == 0)
    }

    @Test func skipsGapsWhereTheMacWasAsleep() {
        var tally = SessionTally(start: start)
        tally.sample(at: start.addingTimeInterval(1), idleSeconds: 0, lidClosed: false, lidMode: false)
        tally.sample(at: start.addingTimeInterval(3_601), idleSeconds: 0, lidClosed: false, lidMode: false)
        #expect(tally.awake == 1)
    }

    @Test func creditsTheIdleStretchOnceYouCountAsAway() {
        var tally = SessionTally(start: start)
        // Active for a minute, then idle from t=60 onward, sampled every second.
        for second in 1...600 {
            let idle = max(0, TimeInterval(second) - 60)
            let now = start.addingTimeInterval(TimeInterval(second))
            tally.sample(at: now, idleSeconds: idle, lidClosed: false, lidMode: false)
        }
        // Away from t=60 to t=600, give or take the sampling second.
        #expect(abs(tally.away - 540) <= 1)
        #expect(tally.awake == 600)
    }

    @Test func tracksLidClosedTimeAndLidMode() {
        var tally = SessionTally(start: start)
        tally.sample(at: start.addingTimeInterval(1), idleSeconds: 0, lidClosed: false, lidMode: true)
        tally.sample(at: start.addingTimeInterval(2), idleSeconds: 0, lidClosed: true, lidMode: true)
        tally.sample(at: start.addingTimeInterval(3), idleSeconds: 0, lidClosed: true, lidMode: true)
        #expect(tally.lidClosed == 2)
        #expect(tally.usedLidMode)
    }
}

struct DailyTotalsTests {
    var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "America/Los_Angeles") ?? .current
        return calendar
    }

    func date(_ day: Int, _ hour: Int) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: 9, day: day, hour: hour)) ?? .distantPast
    }

    @Test func returnsOneEntryPerDayOldestFirst() {
        let days = DailyTotals.make([], days: 7, now: date(29, 12), calendar: calendar)
        #expect(days.count == 7)
        #expect(days.first?.day == calendar.startOfDay(for: date(23, 0)))
        #expect(days.last?.day == calendar.startOfDay(for: date(29, 0)))
    }

    @Test func splitsAnOvernightSessionAcrossMidnight() {
        // 10 PM to 6 AM: 2 hours on the 28th, 6 on the 29th; mostly away.
        let record = SessionRecord(start: date(28, 22), end: date(29, 6), awakeTime: 8 * 3_600, awayTime: 8 * 3_600)
        let days = DailyTotals.make([record], days: 2, now: date(29, 12), calendar: calendar)
        #expect(days[0].awake == 2 * 3_600)
        #expect(days[1].awake == 6 * 3_600)
        #expect(days[1].away == 6 * 3_600)
        #expect(days[1].withYou == 0)
    }
}
