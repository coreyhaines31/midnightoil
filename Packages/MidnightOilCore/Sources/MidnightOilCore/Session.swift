import Foundation

/// When a keep-awake session should stop on its own.
public enum SessionEnd: Equatable, Sendable {
    case indefinite
    case after(TimeInterval)
    case until(Date)

    public func endDate(from start: Date) -> Date? {
        switch self {
        case .indefinite: nil
        case .after(let interval): start.addingTimeInterval(interval)
        case .until(let date): date
        }
    }
}

public struct Session: Equatable, Sendable {
    public let start: Date
    public let end: SessionEnd
    public var allowsDisplaySleep: Bool

    public init(start: Date, end: SessionEnd, allowsDisplaySleep: Bool) {
        self.start = start
        self.end = end
        self.allowsDisplaySleep = allowsDisplaySleep
    }

    public var endDate: Date? { end.endDate(from: start) }

    /// Seconds left, or nil for an indefinite session. Never negative.
    public func remaining(at now: Date) -> TimeInterval? {
        endDate.map { max(0, $0.timeIntervalSince(now)) }
    }

    /// Pushes a timed session's end later. Indefinite sessions are unchanged.
    public func extended(by interval: TimeInterval) -> Session {
        let newEnd: SessionEnd
        switch end {
        case .indefinite: return self
        case .after(let duration): newEnd = .after(duration + interval)
        case .until(let date): newEnd = .until(date.addingTimeInterval(interval))
        }
        return Session(start: start, end: newEnd, allowsDisplaySleep: allowsDisplaySleep)
    }

    public func isFinished(at now: Date) -> Bool {
        guard let endDate else { return false }
        return now >= endDate
    }
}
