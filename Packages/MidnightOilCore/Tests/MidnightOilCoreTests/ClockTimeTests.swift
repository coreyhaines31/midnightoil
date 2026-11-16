import Foundation
@testable import MidnightOilCore
import Testing

struct ClockTimeTests {
    var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "America/Los_Angeles")!
        return calendar
    }
    // Sunday Nov 22 2026, 9:00 PM Pacific: 90 hours ahead is Thursday 3 PM, 90 back Thursday 3 AM.
    let now = Date(timeIntervalSince1970: 1_795_410_000)

    @Test func countsCalendarDaysNotHours() {
        #expect(ClockTime.dayOffset(of: now.addingTimeInterval(3_600), from: now, calendar: calendar) == 0)
        #expect(ClockTime.dayOffset(of: now.addingTimeInterval(4 * 3_600), from: now, calendar: calendar) == 1)
        #expect(ClockTime.dayOffset(of: now.addingTimeInterval(90 * 3_600), from: now, calendar: calendar) == 4)
        #expect(ClockTime.dayOffset(of: now.addingTimeInterval(-90 * 3_600), from: now, calendar: calendar) == -3)
    }

    @Test func farDatesShowTheDateNotAWeekday() {
        let nextWeek = now.addingTimeInterval(8 * 86_400)
        #expect(ClockTime.format(nextWeek, now: now, calendar: calendar)
            == nextWeek.formatted(.dateTime.month(.abbreviated).day().hour().minute()))
        let inThreeDays = now.addingTimeInterval(3 * 86_400)
        #expect(ClockTime.format(inThreeDays, now: now, calendar: calendar)
            == inThreeDays.formatted(.dateTime.weekday(.abbreviated).hour().minute()))
    }
}
