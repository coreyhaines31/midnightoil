import Foundation
@testable import MidnightOilCore
import Testing

struct CLIStatusTests {
    @Test func decodesStatusFromAppsBeforeTheHeatPause() throws {
        let json = Data(#"{"awake":true,"staysAwakeWithLidClosed":true,"allowsDisplaySleep":false}"#.utf8)
        let status = try CLIProtocol.decoder().decode(CLIStatus.self, from: json)
        #expect(status.staysAwakeWithLidClosed)
        #expect(status.lidPausedForHeat == nil)
    }

    @Test func roundTripsTheHeatPause() throws {
        let status = CLIStatus(awake: true, staysAwakeWithLidClosed: true, lidPausedForHeat: true)
        let data = try CLIProtocol.encoder().encode(status)
        #expect(try CLIProtocol.decoder().decode(CLIStatus.self, from: data) == status)
    }
}
