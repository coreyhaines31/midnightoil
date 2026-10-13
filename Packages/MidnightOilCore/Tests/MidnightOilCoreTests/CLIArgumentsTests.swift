import Foundation
@testable import MidnightOilCore
import Testing

struct CLIArgumentsTests {
    let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "America/Los_Angeles")!
        return calendar
    }()

    /// Tuesday, Oct 13 2026, 10:15 PM in Los Angeles.
    var now: Date {
        calendar.date(from: DateComponents(year: 2026, month: 10, day: 13, hour: 22, minute: 15))!
    }

    private func parse(_ arguments: String) throws(CLIUsageError) -> CLICommand {
        try CLIArguments.parse(arguments.split(separator: " ").map(String.init), now: now, calendar: calendar)
    }

    @Test(arguments: [
        ("8h", 28_800.0), ("90m", 5_400), ("1h30m", 5_400), ("45s", 45), ("2d", 172_800), ("1.5h", 5_400)
    ])
    func readsDurations(text: String, seconds: TimeInterval) throws {
        #expect(try CLIArguments.duration(text) == seconds)
    }

    @Test(arguments: ["90", "h", "8x", "", "0m", "1h30"])
    func rejectsUnclearDurations(text: String) {
        #expect(throws: CLIUsageError.self) { try CLIArguments.duration(text) }
    }

    @Test(arguments: [
        ("6am", 6, 0), ("6:30pm", 18, 30), ("11pm", 23, 0), ("12am", 0, 0), ("23:45", 23, 45), ("7", 7, 0)
    ])
    func readsTimesAsTheNextOccurrence(text: String, hour: Int, minute: Int) throws {
        let date = try CLIArguments.time(text, after: now, calendar: calendar)
        let parts = calendar.dateComponents([.day, .hour, .minute], from: date)
        // Anything before 10:15 PM has passed today, so it means tomorrow.
        let expectedDay = hour * 60 + minute > 22 * 60 + 15 ? 13 : 14
        #expect(parts.day == expectedDay)
        #expect(parts.hour == hour)
        #expect(parts.minute == minute)
    }

    @Test(arguments: ["13pm", "25:00", "6:75", "noon", "6:", ":30"])
    func rejectsUnclearTimes(text: String) {
        #expect(throws: CLIUsageError.self) { try CLIArguments.time(text, after: now, calendar: calendar) }
    }

    @Test func startDefaultsToIndefiniteWithTheUsersSettings() throws {
        let command = try parse("start")
        #expect(command == .send(CLIRequest(action: .start), json: false))
        if case .send(let request, _) = command { #expect(request.sessionEnd == .indefinite) }
    }

    @Test func startTakesADurationAndOptions() throws {
        let command = try parse("start --for 2h --lid-closed --allow-display-sleep --json")
        let expected = CLIRequest(
            action: .start, duration: 7_200, staysAwakeWithLidClosed: true, allowsDisplaySleep: true
        )
        #expect(command == .send(expected, json: true))
        #expect(expected.sessionEnd == .after(7_200))
    }

    @Test func startWatchesAProcess() throws {
        let command = try parse("start --while-pid 4242")
        guard case .send(let request, _) = command else { Issue.record("not a send"); return }
        #expect(request.sessionEnd == .whileProcessesRunning([WatchedProcess(pid: 4242, name: "PID 4242")]))
    }

    @Test func startTakesOnlyOneEnd() {
        #expect(throws: CLIUsageError.self) { try parse("start --for 2h --until 6am") }
    }

    @Test func runSplitsItsOptionsFromTheCommand() throws {
        let command = try parse("run --lid-closed -- claude -p --verbose")
        let expected = CLIRequest(action: .start, staysAwakeWithLidClosed: true)
        #expect(command == .run(expected, command: ["claude", "-p", "--verbose"], json: false))
    }

    @Test func runWithoutDashesStartsAtTheFirstWord() throws {
        #expect(try parse("run npm test") == .run(CLIRequest(action: .start), command: ["npm", "test"], json: false))
    }

    @Test func runNeedsACommandAndNoEndTime() {
        #expect(throws: CLIUsageError.self) { try parse("run") }
        #expect(throws: CLIUsageError.self) { try parse("run --for 2h npm test") }
    }

    @Test func stopAndStatus() throws {
        #expect(try parse("stop") == .send(CLIRequest(action: .stop), json: false))
        #expect(try parse("status --json") == .send(CLIRequest(action: .status), json: true))
        #expect(throws: CLIUsageError.self) { try parse("status --for 2h") }
    }

    @Test func helpVersionAndUnknown() throws {
        #expect(try CLIArguments.parse([]) == .help)
        #expect(try parse("--help") == .help)
        #expect(try parse("--version") == .version)
        #expect(throws: CLIUsageError.self) { try parse("sleep") }
        #expect(throws: CLIUsageError.self) { try parse("start --forever") }
    }

    @Test func requestsSurviveTheTripToTheApp() throws {
        let request = CLIRequest(
            action: .start, until: now, pid: 7, processName: "codex", staysAwakeWithLidClosed: true
        )
        let data = try CLIProtocol.encoder().encode(request)
        #expect(try CLIProtocol.decoder().decode(CLIRequest.self, from: data) == request)
    }
}
