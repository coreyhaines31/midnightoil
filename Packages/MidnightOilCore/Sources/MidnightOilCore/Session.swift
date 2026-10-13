import Foundation

public struct WatchedApp: Equatable, Sendable {
    public let bundleIdentifier: String
    public let name: String

    public init(bundleIdentifier: String, name: String) {
        self.bundleIdentifier = bundleIdentifier
        self.name = name
    }
}

/// A process a session waits on, such as a command started with `midnightoil run`.
public struct WatchedProcess: Equatable, Sendable {
    public let pid: Int32
    public let name: String

    public init(pid: Int32, name: String) {
        self.pid = pid
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
    /// Ends once every one of these processes has exited.
    case whileProcessesRunning([WatchedProcess])

    /// Nil when the session ends on an event rather than at a time.
    public func endDate(from start: Date) -> Date? {
        switch self {
        case .indefinite, .whileAppRunning, .whileDownloading, .whileProcessesRunning: nil
        case .after(let interval): start.addingTimeInterval(interval)
        case .until(let date): date
        }
    }
}

public enum SessionSource: Equatable, Sendable {
    case manual
    case trigger(id: UUID, name: String)
    case schedule(id: UUID, name: String)

    /// The trigger or schedule running this session, nil for one you started.
    public var automaticID: UUID? {
        switch self {
        case .manual: nil
        case .trigger(let id, _), .schedule(let id, _): id
        }
    }
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
        case .indefinite, .whileAppRunning, .whileDownloading, .whileProcessesRunning: return self
        case .after(let duration): newEnd = .after(duration + interval)
        case .until(let date): newEnd = .until(date.addingTimeInterval(interval))
        }
        var extended = self
        extended.end = newEnd
        return extended
    }

    /// Adds a process to a session that waits on processes, so it lasts until both are done.
    /// Other sessions are unchanged.
    public func joining(_ process: WatchedProcess) -> Session {
        guard case .whileProcessesRunning(let processes) = end else { return self }
        var joined = self
        joined.end = .whileProcessesRunning(processes.filter { $0.pid != process.pid } + [process])
        return joined
    }

    /// Drops processes that have exited. Returns nil once none are left.
    public func keepingProcesses(where isRunning: (Int32) -> Bool) -> Session? {
        guard case .whileProcessesRunning(let processes) = end else { return self }
        let running = processes.filter { isRunning($0.pid) }
        guard !running.isEmpty else { return nil }
        var kept = self
        kept.end = .whileProcessesRunning(running)
        return kept
    }

    public func isFinished(at now: Date) -> Bool {
        guard let endDate else { return false }
        return now >= endDate
    }
}
