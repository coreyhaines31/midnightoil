import Foundation

/// What the `midnightoil` command asks the running app to do. Sent as JSON over a socket
/// that only the signed-in user can open, one request per connection.
public struct CLIRequest: Codable, Equatable, Sendable {
    public enum Action: String, Codable, Sendable {
        case start, stop, status
    }

    public var action: Action
    /// `--for`: how long to stay awake.
    public var duration: TimeInterval?
    /// `--until`: when to stop.
    public var until: Date?
    /// `run` and `--while-pid`: stay awake while this process runs.
    public var pid: Int32?
    public var processName: String?
    /// Nil keeps the user's default from Settings.
    public var staysAwakeWithLidClosed: Bool?
    public var allowsDisplaySleep: Bool?

    public init(
        action: Action,
        duration: TimeInterval? = nil,
        until: Date? = nil,
        pid: Int32? = nil,
        processName: String? = nil,
        staysAwakeWithLidClosed: Bool? = nil,
        allowsDisplaySleep: Bool? = nil
    ) {
        self.action = action
        self.duration = duration
        self.until = until
        self.pid = pid
        self.processName = processName
        self.staysAwakeWithLidClosed = staysAwakeWithLidClosed
        self.allowsDisplaySleep = allowsDisplaySleep
    }

    /// The session this request starts. Nil for stop and status.
    public var sessionEnd: SessionEnd? {
        guard action == .start else { return nil }
        if let pid { return .whileProcessesRunning([WatchedProcess(pid: pid, name: processName ?? "PID \(pid)")]) }
        if let duration { return .after(duration) }
        if let until { return .until(until) }
        return .indefinite
    }
}

/// The app's answer: what's running now, plus anything the user should know.
public struct CLIResponse: Codable, Equatable, Sendable {
    public var error: String?
    /// Things that worked differently than asked, like closed-lid mode not being set up.
    public var notes: [String]
    public var status: CLIStatus

    public init(error: String? = nil, notes: [String] = [], status: CLIStatus) {
        self.error = error
        self.notes = notes
        self.status = status
    }
}

public struct CLIStatus: Codable, Equatable, Sendable {
    public var awake: Bool
    /// Like "Until you end it" or "2h 05m left · until 6:00 AM".
    public var detail: String?
    /// "you", or the trigger or schedule that started it.
    public var startedBy: String?
    public var started: Date?
    public var ends: Date?
    public var staysAwakeWithLidClosed: Bool
    public var allowsDisplaySleep: Bool
    public var processes: [String]?

    public init(
        awake: Bool,
        detail: String? = nil,
        startedBy: String? = nil,
        started: Date? = nil,
        ends: Date? = nil,
        staysAwakeWithLidClosed: Bool = false,
        allowsDisplaySleep: Bool = false,
        processes: [String]? = nil
    ) {
        self.awake = awake
        self.detail = detail
        self.startedBy = startedBy
        self.started = started
        self.ends = ends
        self.staysAwakeWithLidClosed = staysAwakeWithLidClosed
        self.allowsDisplaySleep = allowsDisplaySleep
        self.processes = processes
    }

    public static let asleep = CLIStatus(awake: false)
}

public enum CLIProtocol {
    /// Where the app listens. Kept short enough for a socket path (104 bytes).
    public static var socketURL: URL {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appending(path: "Midnight Oil/cli.sock")
    }

    public static let bundleIdentifier = "app.midnightoil.MidnightOil"

    public static func encoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.sortedKeys]
        return encoder
    }

    public static func decoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}
