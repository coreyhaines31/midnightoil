import Foundation
@testable import MidnightOilCore
import Testing

struct UntilTimesTests {
    var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "America/Los_Angeles") ?? .current
        return calendar
    }

    func date(_ hour: Int, _ minute: Int) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: 9, day: 29, hour: hour, minute: minute)) ?? .distantPast
    }

    @Test func offersTheNextHoursOnTheHour() {
        let hours = UntilTimes.upcomingHours(after: date(14, 10), count: 3, calendar: calendar)
        #expect(hours == [date(15, 0), date(16, 0), date(17, 0)])
    }

    @Test func skipsAnHourThatIsTooClose() {
        let hours = UntilTimes.upcomingHours(after: date(14, 50), count: 2, calendar: calendar)
        #expect(hours == [date(16, 0), date(17, 0)])
    }

    @Test func rollsOverMidnight() {
        let hours = UntilTimes.upcomingHours(after: date(23, 10), count: 1, calendar: calendar)
        let nextMidnight = calendar.date(from: DateComponents(year: 2026, month: 9, day: 30, hour: 0))
        #expect(hours == [nextMidnight])
    }
}
