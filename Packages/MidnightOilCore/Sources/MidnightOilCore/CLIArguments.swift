import Foundation

/// What the `midnightoil` command was asked to do.
public enum CLICommand: Equatable, Sendable {
    case send(CLIRequest, json: Bool)
    /// Start a session tied to `command`, run it, and exit with its status.
    case run(CLIRequest, command: [String], json: Bool)
    case help
    case version
}

public struct CLIUsageError: Error, Equatable, Sendable {
    public let message: String

    public init(_ message: String) {
        self.message = message
    }
}

public enum CLIArguments {
    public static func parse(
        _ arguments: [String],
        now: Date = .now,
        calendar: Calendar = .current
    ) throws(CLIUsageError) -> CLICommand {
        guard let name = arguments.first else { return .help }
        let rest = Array(arguments.dropFirst())
        switch name {
        case "help", "-h", "--help": return .help
        case "version", "-v", "--version": return .version
        case "stop":
            return .send(CLIRequest(action: .stop), json: try takeJSONOnly(rest, command: name))
        case "status":
            return .send(CLIRequest(action: .status), json: try takeJSONOnly(rest, command: name))
        case "start": return try parseStart(rest, now: now, calendar: calendar)
        case "run": return try parseRun(rest, now: now, calendar: calendar)
        default:
            throw CLIUsageError("Unknown command: \(name)")
        }
    }

    private static func parseStart(
        _ arguments: [String],
        now: Date,
        calendar: Calendar
    ) throws(CLIUsageError) -> CLICommand {
        var rest = arguments
        var request = CLIRequest(action: .start)
        var json = false
        while let option = rest.first {
            rest.removeFirst()
            try apply(option, to: &request, json: &json, rest: &rest, now: now, calendar: calendar)
        }
        let ends = [request.duration != nil, request.until != nil, request.pid != nil].filter { $0 }
        if ends.count > 1 { throw CLIUsageError("Choose one of --for, --until, or --while-pid.") }
        return .send(request, json: json)
    }

    private static func parseRun(
        _ arguments: [String],
        now: Date,
        calendar: Calendar
    ) throws(CLIUsageError) -> CLICommand {
        var rest = arguments
        var request = CLIRequest(action: .start)
        var json = false
        while let option = rest.first, option.hasPrefix("-") {
            rest.removeFirst()
            if option == "--" { break }
            if ["--for", "--until", "--while-pid"].contains(option) {
                throw CLIUsageError("run keeps your Mac awake until the command finishes, so it takes no \(option).")
            }
            guard ["--lid-closed", "--allow-display-sleep", "--json"].contains(option) else {
                throw CLIUsageError("Unknown option for run: \(option)")
            }
            try apply(option, to: &request, json: &json, rest: &rest, now: now, calendar: calendar)
        }
        guard !rest.isEmpty else { throw CLIUsageError("Give run a command, like: midnightoil run -- npm test") }
        return .run(request, command: rest, json: json)
    }

    private static func takeJSONOnly(_ rest: [String], command: String) throws(CLIUsageError) -> Bool {
        if let extra = rest.first(where: { $0 != "--json" }) {
            throw CLIUsageError("Unknown option for \(command): \(extra)")
        }
        return !rest.isEmpty
    }

    // swiftlint:disable:next function_parameter_count
    private static func apply(
        _ option: String,
        to request: inout CLIRequest,
        json: inout Bool,
        rest: inout [String],
        now: Date,
        calendar: Calendar
    ) throws(CLIUsageError) {
        switch option {
        case "--lid-closed": request.staysAwakeWithLidClosed = true
        case "--allow-display-sleep": request.allowsDisplaySleep = true
        case "--json": json = true
        case "--for":
            request.duration = try duration(try value(for: option, from: &rest))
        case "--until":
            request.until = try time(try value(for: option, from: &rest), after: now, calendar: calendar)
        case "--while-pid":
            let text = try value(for: option, from: &rest)
            guard let pid = Int32(text), pid > 0 else {
                throw CLIUsageError("--while-pid needs a process ID, like 4242.")
            }
            request.pid = pid
        default:
            throw CLIUsageError("Unknown option: \(option)")
        }
    }

    private static func value(for option: String, from rest: inout [String]) throws(CLIUsageError) -> String {
        guard let value = rest.first, !value.hasPrefix("--") else {
            throw CLIUsageError("\(option) needs a value.")
        }
        rest.removeFirst()
        return value
    }

    /// "8h", "90m", "1h30m", "45s", "2d". A unit is required, since a bare number is ambiguous.
    public static func duration(_ text: String) throws(CLIUsageError) -> TimeInterval {
        let units: [Character: TimeInterval] = ["d": 86_400, "h": 3_600, "m": 60, "s": 1]
        var total: TimeInterval = 0
        var number = ""
        for character in text.lowercased() {
            if character.isNumber || character == "." {
                number.append(character)
            } else if let unit = units[character], let amount = Double(number) {
                total += amount * unit
                number = ""
            } else {
                throw CLIUsageError("Couldn't read “\(text)” as a duration. Try 90m, 2h, or 1h30m.")
            }
        }
        guard number.isEmpty, total > 0 else {
            throw CLIUsageError("Couldn't read “\(text)” as a duration. Try 90m, 2h, or 1h30m.")
        }
        return total
    }

    /// "6am", "6:30pm", "18:30", "7". The next time it comes around, today or tomorrow.
    public static func time(
        _ text: String,
        after now: Date,
        calendar: Calendar = .current
    ) throws(CLIUsageError) -> Date {
        let failure = CLIUsageError("Couldn't read “\(text)” as a time. Try 6am, 6:30pm, or 18:30.")
        var clock = text.lowercased().replacingOccurrences(of: " ", with: "")
        var meridiem: String?
        for suffix in ["am", "pm"] where clock.hasSuffix(suffix) {
            meridiem = suffix
            clock.removeLast(2)
        }
        let parts = clock.split(separator: ":", omittingEmptySubsequences: false)
        guard (1...2).contains(parts.count),
              parts.allSatisfy({ !$0.isEmpty && $0.allSatisfy(\.isNumber) }),
              var hour = Int(parts[0]),
              let minute = parts.count == 2 ? Int(parts[1]) : 0,
              (0...59).contains(minute)
        else { throw failure }
        if let meridiem {
            guard (1...12).contains(hour) else { throw failure }
            hour = hour % 12 + (meridiem == "pm" ? 12 : 0)
        }
        guard (0...23).contains(hour),
              let date = calendar.nextDate(
                after: now,
                matching: DateComponents(hour: hour, minute: minute, second: 0),
                matchingPolicy: .nextTime
              )
        else { throw failure }
        return date
    }
}
