import Foundation

/// Why a session stopped.
public enum SessionEndCause: String, Codable, Sendable, CaseIterable {
    case you
    case timeUp
    case appQuit
    case downloadFinished
    case lowBattery
    case unplugged
    case triggerEnded
    case scheduleEnded
    case schedulePaused
    case replaced
    case midnightOilQuit
    /// A value written by a newer version of the app.
    case unknown

    public init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self)
        self = Self(rawValue: raw) ?? .unknown
    }

    public var label: String {
        switch self {
        case .you: "You ended it"
        case .timeUp: "Time ran out"
        case .appQuit: "The app quit"
        case .downloadFinished: "Download finished"
        case .lowBattery: "Battery got low"
        case .unplugged: "Unplugged"
        case .triggerEnded: "Trigger stopped matching"
        case .scheduleEnded: "Schedule ended"
        case .schedulePaused: "Schedule paused"
        case .replaced: "Replaced by a new session"
        case .midnightOilQuit: "Midnight Oil quit"
        case .unknown: "Ended"
        }
    }
}

/// One finished session, kept for the Statistics tab. Fields added after 1.0
/// are optional so older history files still load.
public struct SessionRecord: Codable, Equatable, Identifiable, Sendable {
    public var id: UUID
    public var start: Date
    public var end: Date
    /// The trigger that started it, or nil for a manual session.
    public var triggerName: String?
    /// The schedule that started it, if any.
    public var scheduleName: String?
    public var endCause: SessionEndCause?
    /// The app or file the session followed, if any.
    public var subject: String?
    /// Time the Mac was actually awake, excluding any sleep in between.
    public var awakeTime: TimeInterval?
    /// Time the Mac stayed awake while nobody was using it.
    public var awayTime: TimeInterval?
    public var lidClosedTime: TimeInterval?
    public var usedLidMode: Bool?
    public var batteryStart: Int?
    public var batteryEnd: Int?

    public init(
        id: UUID = UUID(),
        start: Date,
        end: Date,
        triggerName: String? = nil,
        scheduleName: String? = nil,
        endCause: SessionEndCause? = nil,
        subject: String? = nil,
        awakeTime: TimeInterval? = nil,
        awayTime: TimeInterval? = nil,
        lidClosedTime: TimeInterval? = nil,
        usedLidMode: Bool? = nil,
        batteryStart: Int? = nil,
        batteryEnd: Int? = nil
    ) {
        self.id = id
        self.start = start
        self.end = end
        self.triggerName = triggerName
        self.scheduleName = scheduleName
        self.endCause = endCause
        self.subject = subject
        self.awakeTime = awakeTime
        self.awayTime = awayTime
        self.lidClosedTime = lidClosedTime
        self.usedLidMode = usedLidMode
        self.batteryStart = batteryStart
        self.batteryEnd = batteryEnd
    }

    public var duration: TimeInterval { max(0, end.timeIntervalSince(start)) }

    /// Measured awake time when we have it; wall-clock length for older records.
    public var awake: TimeInterval { awakeTime ?? duration }

    public var away: TimeInterval { min(awayTime ?? 0, awake) }

    /// "7h 48m awake, 6h 55m while you were away"
    public var headline: String {
        let awakeText = "\(RemainingTime.short(awake)) awake"
        guard away >= 60 else { return awakeText }
        return "\(awakeText), \(RemainingTime.short(away)) while you were away"
    }
}

/// Accumulates what happened during a running session from periodic samples.
///
/// Only time between samples while the Mac was awake counts. Sleep is excluded
/// two ways: explicitly, via `resumeAfterSleep`, and as a fallback, by ignoring
/// any gap longer than `maxGap`.
public struct SessionTally: Equatable, Sendable {
    /// Idle for this long and you count as away.
    public static let awayThreshold: TimeInterval = 5 * 60
    /// Gaps longer than this mean the Mac was asleep, so they don't count as awake.
    public static let maxGap: TimeInterval = 30

    public private(set) var awake: TimeInterval = 0
    public private(set) var away: TimeInterval = 0
    public private(set) var lidClosed: TimeInterval = 0
    public private(set) var usedLidMode = false

    private var lastSample: Date
    private var wasAway = false
    /// Awake time since your last input. Unlike the system idle clock, it
    /// doesn't grow while the Mac sleeps.
    private var idleStreak: TimeInterval = 0

    public init(start: Date) {
        lastSample = start
    }

    public mutating func sample(at now: Date, idleSeconds: TimeInterval, lidClosed isLidClosed: Bool, lidMode: Bool) {
        let gap = now.timeIntervalSince(lastSample)
        lastSample = now
        if lidMode { usedLidMode = true }
        guard gap > 0, gap <= Self.maxGap else { return }

        awake += gap
        if isLidClosed { lidClosed += gap }
        // Input during the gap means only the part after it was idle.
        idleStreak = idleSeconds >= gap ? idleStreak + gap : idleSeconds

        let isAway = idleSeconds >= Self.awayThreshold
        if isAway {
            // The first away sample credits the whole idle streak that led to it.
            away += wasAway ? gap : idleStreak
            away = min(away, awake)
        }
        wasAway = isAway
    }

    /// Call on wake so the time asleep is never counted, however short.
    public mutating func resumeAfterSleep(at now: Date) {
        lastSample = now
    }
}

public struct SessionStatistics: Equatable, Sendable {
    public var sessionCount: Int
    public var totalAwake: TimeInterval
    public var totalAway: TimeInterval
    public var longest: TimeInterval
    public var awakeThisWeek: TimeInterval
    public var awayThisWeek: TimeInterval
    public var lidClosedTotal: TimeInterval
    public var triggeredCount: Int

    public init(
        sessionCount: Int = 0,
        totalAwake: TimeInterval = 0,
        totalAway: TimeInterval = 0,
        longest: TimeInterval = 0,
        awakeThisWeek: TimeInterval = 0,
        awayThisWeek: TimeInterval = 0,
        lidClosedTotal: TimeInterval = 0,
        triggeredCount: Int = 0
    ) {
        self.sessionCount = sessionCount
        self.totalAwake = totalAwake
        self.totalAway = totalAway
        self.longest = longest
        self.awakeThisWeek = awakeThisWeek
        self.awayThisWeek = awayThisWeek
        self.lidClosedTotal = lidClosedTotal
        self.triggeredCount = triggeredCount
    }

    public static func summarize(_ records: [SessionRecord], now: Date = .now, calendar: Calendar = .current) -> Self {
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        let thisWeek = records.filter { $0.end >= weekStart }
        return SessionStatistics(
            sessionCount: records.count,
            totalAwake: records.reduce(0) { $0 + $1.awake },
            totalAway: records.reduce(0) { $0 + $1.away },
            longest: records.map(\.awake).max() ?? 0,
            awakeThisWeek: thisWeek.reduce(0) { $0 + $1.awake },
            awayThisWeek: thisWeek.reduce(0) { $0 + $1.away },
            lidClosedTotal: records.reduce(0) { $0 + ($1.lidClosedTime ?? 0) },
            triggeredCount: records.filter { $0.triggerName != nil }.count
        )
    }
}

/// Awake and away time for one calendar day, for the weekly chart.
public struct DayTotal: Equatable, Identifiable, Sendable {
    public var day: Date
    public var awake: TimeInterval
    public var away: TimeInterval

    public var id: Date { day }
    public var withYou: TimeInterval { max(0, awake - away) }
}

public enum DailyTotals {
    /// The last `days` days ending today, oldest first. A session that crosses
    /// midnight is split across both days in proportion to its wall-clock time.
    public static func make(
        _ records: [SessionRecord],
        days: Int,
        now: Date = .now,
        calendar: Calendar = .current
    ) -> [DayTotal] {
        let today = calendar.startOfDay(for: now)
        let starts = (0..<days).reversed().compactMap { calendar.date(byAdding: .day, value: -$0, to: today) }
        return starts.map { dayStart in
            let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) ?? dayStart
            var total = DayTotal(day: dayStart, awake: 0, away: 0)
            for record in records where record.end > dayStart && record.start < dayEnd && record.duration > 0 {
                let overlap = min(record.end, dayEnd).timeIntervalSince(max(record.start, dayStart))
                let share = overlap / record.duration
                total.awake += record.awake * share
                total.away += record.away * share
            }
            return total
        }
    }
}
