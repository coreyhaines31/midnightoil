import Foundation

public struct WatchedApp: Equatable, Sendable {
    public let bundleIdentifier: String
    public let name: String

    public init(bundleIdentifier: String, name: String) {
        self.bundleIdentifier = bundleIdentifier
        self.name = name
    }
}

/// When a keep-awake session should stop on its own.
public enum SessionEnd: Equatable, Sendable {
    case indefinite
    case after(TimeInterval)
    case until(Date)
    case whileAppRunning(WatchedApp)
    case whileDownloading(URL)

    /// Nil when the session ends on an event rather than at a time.
    public func endDate(from start: Date) -> Date? {
        switch self {
        case .indefinite, .whileAppRunning, .whileDownloading: nil
        case .after(let interval): start.addingTimeInterval(interval)
        case .until(let date): date
        }
    }
}

public enum SessionSource: Equatable, Sendable {
    case manual
    case trigger(id: UUID, name: String)
}

public struct Session: Equatable, Sendable {
    public let start: Date
    public let source: SessionSource
    public private(set) var end: SessionEnd
    public var allowsDisplaySleep: Bool
    /// Keeps a laptop running with its lid shut (needs the privileged helper).
    public var staysAwakeWithLidClosed: Bool

    public init(
        start: Date,
        end: SessionEnd,
        allowsDisplaySleep: Bool,
        staysAwakeWithLidClosed: Bool = false,
        source: SessionSource = .manual
    ) {
        self.start = start
        self.source = source
        self.end = end
        self.allowsDisplaySleep = allowsDisplaySleep
        self.staysAwakeWithLidClosed = staysAwakeWithLidClosed
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
        case .indefinite, .whileAppRunning, .whileDownloading: return self
        case .after(let duration): newEnd = .after(duration + interval)
        case .until(let date): newEnd = .until(date.addingTimeInterval(interval))
        }
        var extended = self
        extended.end = newEnd
        return extended
    }

    public func isFinished(at now: Date) -> Bool {
        guard let endDate else { return false }
        return now >= endDate
    }
}
