import Foundation
@testable import MidnightOilCore
import Testing

struct SessionStatisticsTests {
    var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "America/Los_Angeles") ?? .current
        return calendar
    }

    func date(_ day: Int, _ hour: Int) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: 9, day: day, hour: hour)) ?? .distantPast
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
        let stats = SessionStatistics.summarize([], now: date(29, 16), calendar: calendar)
        let zeros = SessionStatistics(sessionCount: 0, totalAwake: 0, longest: 0, awakeThisWeek: 0, triggeredCount: 0)
        #expect(stats == zeros)
    }

    @Test func durationNeverGoesNegative() {
        #expect(SessionRecord(start: date(29, 15), end: date(29, 14)).duration == 0)
    }
}
