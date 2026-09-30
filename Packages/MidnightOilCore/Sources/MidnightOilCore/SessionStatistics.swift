import Foundation

/// One finished session, kept for the Statistics tab.
public struct SessionRecord: Codable, Equatable, Identifiable, Sendable {
    public var id: UUID
    public var start: Date
    public var end: Date
    /// The trigger that started it, or nil for a manual session.
    public var triggerName: String?

    public init(id: UUID = UUID(), start: Date, end: Date, triggerName: String? = nil) {
        self.id = id
        self.start = start
        self.end = end
        self.triggerName = triggerName
    }

    public var duration: TimeInterval { max(0, end.timeIntervalSince(start)) }
}

public struct SessionStatistics: Equatable, Sendable {
    public var sessionCount: Int
    public var totalAwake: TimeInterval
    public var longest: TimeInterval
    public var awakeThisWeek: TimeInterval
    public var triggeredCount: Int

    public static func summarize(_ records: [SessionRecord], now: Date = .now, calendar: Calendar = .current) -> Self {
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        return SessionStatistics(
            sessionCount: records.count,
            totalAwake: records.reduce(0) { $0 + $1.duration },
            longest: records.map(\.duration).max() ?? 0,
            awakeThisWeek: records.filter { $0.end >= weekStart }.reduce(0) { $0 + $1.duration },
            triggeredCount: records.filter { $0.triggerName != nil }.count
        )
    }
}
