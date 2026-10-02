import Foundation
import MidnightOilCore
@testable import MidnightOilTeams
import Testing

struct FleetReportTests {
    let device = TeamsDevice(id: "mac_1", label: nil, appVersion: "1.4.0")
    let power = PowerState(batteryPercent: 64, isOnBattery: true)

    @Test func anIdleMacReportsAsleep() throws {
        let report = FleetReport(device: device, session: nil, power: power, event: nil)
        #expect(!report.awake)
        #expect(report.session == nil)
        #expect(report.event == nil)
        let json = String(bytes: try report.body(), encoding: .utf8) ?? ""
        #expect(json.contains(#""onBattery":true"#))
        #expect(!json.contains("label"))
    }

    @Test func aScheduledSessionIsNamed() {
        let start = Date(timeIntervalSince1970: 1_790_000_000)
        let session = Session(
            start: start, end: .until(start.addingTimeInterval(3_600)), allowsDisplaySleep: false,
            staysAwakeWithLidClosed: true, source: .schedule(id: UUID(), name: "Overnight")
        )
        let report = FleetReport(device: device, session: session, power: power, event: .started(session))
        #expect(report.awake)
        #expect(report.session?.source == "schedule")
        #expect(report.session?.name == "Overnight")
        #expect(report.session?.endsAt == start.addingTimeInterval(3_600))
        #expect(report.session?.lidMode == true)
        #expect(report.event?.event == "session.started")
    }

    @Test func aKnownEndTimeOverridesTheSessions() {
        let start = Date(timeIntervalSince1970: 1_790_000_000)
        let session = Session(
            start: start, end: .indefinite, allowsDisplaySleep: false, source: .schedule(id: UUID(), name: "Work")
        )
        let windowEnd = start.addingTimeInterval(8 * 3_600)
        let report = FleetReport(
            device: device, session: session, endsAt: windowEnd, power: power, event: .started(session)
        )
        #expect(report.session?.endsAt == windowEnd)
        #expect(report.event?.session.endsAt == windowEnd)
    }

    @Test func theReplyMayCarryANewKey() throws {
        let reply = try JSONDecoder().decode(FleetReply.self, from: Data(#"{"licenseKey":"MO1-abc.def"}"#.utf8))
        #expect(reply.licenseKey == "MO1-abc.def")
        #expect(try JSONDecoder().decode(FleetReply.self, from: Data("{}".utf8)).licenseKey == nil)
    }
}
