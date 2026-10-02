import CryptoKit
import Foundation
import MidnightOilCore

/// The Mac a report comes from. The id is random, made once per Mac; the label is whatever
/// the organization sets in its profile. The computer's own name is never sent.
public struct TeamsDevice: Codable, Equatable, Sendable {
    public var id: String
    public var label: String?
    public var appVersion: String

    public init(id: String, label: String?, appVersion: String) {
        self.id = id
        self.label = label
        self.appVersion = appVersion
    }
}

/// The JSON body Midnight Oil posts to an organization's webhook.
public struct WebhookPayload: Codable, Equatable, Sendable {
    public struct SessionInfo: Codable, Equatable, Sendable {
        public var startedAt: Date
        public var endsAt: Date?
        public var endedAt: Date?
        /// "manual", "schedule", or "trigger".
        public var source: String
        /// The schedule or trigger's name.
        public var sourceName: String?
        public var allowsDisplaySleep: Bool
        public var staysAwakeWithLidClosed: Bool
        public var endCause: String?
        public var awakeSeconds: Int?
        public var awaySeconds: Int?
    }

    /// "session.started" or "session.ended".
    public var event: String
    /// Unique per delivery, so a receiver can ignore retries it already handled.
    public var id: String
    public var occurredAt: Date
    public var device: TeamsDevice
    public var session: SessionInfo

    /// `endsAt` is when the session is expected to end, if the caller knows better than the session
    /// itself (a schedule's window, or an organization's time limit).
    public init(
        _ event: SessionEvent,
        device: TeamsDevice,
        endsAt: Date? = nil,
        id: UUID = UUID(),
        at now: Date = .now
    ) {
        self.id = id.uuidString.lowercased()
        self.occurredAt = now
        self.device = device
        switch event {
        case .started(let session):
            self.event = "session.started"
            self.session = Self.info(session, record: nil, endsAt: endsAt)
        case .ended(let session, let record):
            self.event = "session.ended"
            self.session = Self.info(session, record: record, endsAt: endsAt)
        }
    }

    private static func info(_ session: Session, record: SessionRecord?, endsAt: Date?) -> SessionInfo {
        let (source, name): (String, String?) = switch session.source {
        case .manual: ("manual", nil)
        case .schedule(_, let name): ("schedule", name)
        case .trigger(_, let name): ("trigger", name)
        }
        return SessionInfo(
            startedAt: session.start,
            endsAt: endsAt ?? session.endDate,
            endedAt: record?.end,
            source: source,
            sourceName: name,
            allowsDisplaySleep: session.allowsDisplaySleep,
            staysAwakeWithLidClosed: session.staysAwakeWithLidClosed,
            endCause: record?.endCause?.rawValue,
            awakeSeconds: record.map { Int($0.awake.rounded()) },
            awaySeconds: record.map { Int($0.away.rounded()) }
        )
    }
}

public enum SessionWebhook {
    public static let signatureHeader = "X-MidnightOil-Signature"

    public static func body(for payload: WebhookPayload) throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.sortedKeys]
        return try encoder.encode(payload)
    }

    /// `t=<unix seconds>,v1=<hex HMAC-SHA256 of "<t>.<body>">`, the same scheme Stripe uses,
    /// so receivers can check the request came from their Macs and isn't a replay.
    public static func signature(body: Data, secret: String, at now: Date = .now) -> String {
        let timestamp = String(Int(now.timeIntervalSince1970))
        var message = Data((timestamp + ".").utf8)
        message.append(body)
        let mac = HMAC<SHA256>.authenticationCode(for: message, using: SymmetricKey(data: Data(secret.utf8)))
        return "t=\(timestamp),v1=" + mac.map { String(format: "%02x", $0) }.joined()
    }

    /// Slack incoming webhooks want `{"text": …}`, so those URLs get a readable message instead.
    public static func isSlack(_ url: URL) -> Bool {
        url.host == "hooks.slack.com"
    }

    public static func slackText(for payload: WebhookPayload) -> String {
        let mac = payload.device.label ?? "A Mac"
        let what = switch (payload.session.source, payload.session.sourceName) {
        case ("schedule", let name?): " on the “\(name)” schedule"
        case ("trigger", let name?): " by the “\(name)” trigger"
        default: ""
        }
        if payload.event == "session.started" {
            return "🔥 \(mac) is staying awake\(what)."
        }
        let awake = payload.session.awakeSeconds.map { " after \(RemainingTime.short(TimeInterval($0)))" } ?? ""
        return "\(mac) can sleep again\(awake)\(what)."
    }
}
