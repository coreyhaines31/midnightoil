import Foundation

/// How the menu prints a moment near now: "5:00 PM" today, "Wed 1:00 AM" within six days either
/// side (no weekday repeats), and "Nov 24, 5:00 PM" further out, so a long session never reads as today.
public enum ClockTime {
    public static func format(_ date: Date, now: Date = .now, calendar: Calendar = .current) -> String {
        let days = dayOffset(of: date, from: now, calendar: calendar)
        if days == 0 { return date.formatted(.dateTime.hour().minute()) }
        if abs(days) < 7 { return date.formatted(.dateTime.weekday(.abbreviated).hour().minute()) }
        return date.formatted(.dateTime.month(.abbreviated).day().hour().minute())
    }

    /// Calendar days from `now` to `date`: 0 today, 1 tomorrow, -1 yesterday.
    public static func dayOffset(of date: Date, from now: Date, calendar: Calendar = .current) -> Int {
        let from = calendar.startOfDay(for: now)
        return calendar.dateComponents([.day], from: from, to: calendar.startOfDay(for: date)).day ?? 0
    }
}
