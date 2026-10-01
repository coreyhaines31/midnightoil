import Foundation
import MidnightOilCore
@testable import MidnightOilTeams
import Testing

struct SessionWebhookTests {
    let device = TeamsDevice(id: "dev_1", label: "Build Mac 3", appVersion: "1.4.0")
    let start = Date(timeIntervalSince1970: 1_790_000_000)

    var scheduled: Session {
        Session(
            start: start, end: .indefinite, allowsDisplaySleep: true,
            source: .schedule(id: UUID(), name: "Overnight")
        )
    }

    @Test func aStartedEventDescribesTheSession() throws {
        let payload = WebhookPayload(.started(scheduled), device: device, at: start)
        #expect(payload.event == "session.started")
        #expect(payload.session.source == "schedule")
        #expect(payload.session.sourceName == "Overnight")
        #expect(payload.session.endedAt == nil)
        let json = String(bytes: try SessionWebhook.body(for: payload), encoding: .utf8) ?? ""
        #expect(json.contains(#""occurredAt":"2026-09-21T"#))
        #expect(json.contains(#""label":"Build Mac 3""#))
    }

    @Test func anEndedEventCarriesTheRecord() {
        let record = SessionRecord(
            start: start, end: start.addingTimeInterval(3_600), endCause: .scheduleEnded,
            awakeTime: 3_600, awayTime: 3_000
        )
        let payload = WebhookPayload(.ended(scheduled, record), device: device)
        #expect(payload.event == "session.ended")
        #expect(payload.session.endCause == "scheduleEnded")
        #expect(payload.session.awakeSeconds == 3_600)
        #expect(payload.session.awaySeconds == 3_000)
    }

    /// Checked against: printf '1790000000.{"a":1}' | openssl dgst -sha256 -hmac 'whsec_test'
    @Test func theSignatureMatchesStripesScheme() {
        let signature = SessionWebhook.signature(body: Data(#"{"a":1}"#.utf8), secret: "whsec_test", at: start)
        #expect(signature == "t=1790000000,v1=f08690bbaaecbd1607eb9af71f092a9f7054e2b83f8b9d6a0690744d24fc6059")
    }

    @Test func slackGetsReadableText() throws {
        let url = try #require(URL(string: "https://hooks.slack.com/services/T000/B000/XXX"))
        #expect(SessionWebhook.isSlack(url))
        #expect(!SessionWebhook.isSlack(try #require(URL(string: "https://example.com/hooks"))))
        let started = WebhookPayload(.started(scheduled), device: device)
        #expect(SessionWebhook.slackText(for: started) == "🔥 Build Mac 3 is staying awake on the “Overnight” schedule.")
    }
}
