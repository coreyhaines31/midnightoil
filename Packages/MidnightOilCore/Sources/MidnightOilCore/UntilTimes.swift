import Foundation

/// The "Until…" choices offered in the menu: the next few times on the hour.
public enum UntilTimes {
    public static func upcomingHours(after now: Date, count: Int, calendar: Calendar = .current) -> [Date] {
        var dates: [Date] = []
        var cursor = now
        while dates.count < count,
              let next = calendar.nextDate(
                after: cursor,
                matching: DateComponents(minute: 0, second: 0),
                matchingPolicy: .nextTime
              ) {
            // Skip an hour that's less than 15 minutes away; it isn't worth a session.
            if next.timeIntervalSince(now) >= 15 * 60 {
                dates.append(next)
            }
            cursor = next
        }
        return dates
    }
}
