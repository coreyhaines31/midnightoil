import Foundation
import MidnightOilCore

/// What a Mac tells the fleet dashboard: who it is, whether it's being kept awake and why,
/// and the session event that prompted the report, if any. Sent only when the organization's
/// profile turns fleet reporting on.
public struct FleetReport: Codable, Equatable, Sendable {
    public struct SessionState: Codable, Equatable, Sendable {
        public var source: String
        public var name: String?
        public var startedAt: Date
        public var endsAt: Date?
        public var lidMode: Bool
    }

    public struct Battery: Codable, Equatable, Sendable {
        public var percent: Int?
        public var onBattery: Bool
    }

    public var device: TeamsDevice
    public var awake: Bool
    public var session: SessionState?
    public var battery: Battery
    /// The event behind this report; nil for the regular heartbeat.
    public var event: WebhookPayload?

    public init(device: TeamsDevice, session: Session?, power: PowerState, event: SessionEvent?, at now: Date = .now) {
        self.device = device
        self.awake = session != nil
        self.session = session.map { session in
            let (source, name): (String, String?) = switch session.source {
            case .manual: ("manual", nil)
            case .schedule(_, let name): ("schedule", name)
            case .trigger(_, let name): ("trigger", name)
            }
            return SessionState(
                source: source, name: name, startedAt: session.start,
                endsAt: session.endDate, lidMode: session.staysAwakeWithLidClosed
            )
        }
        self.battery = Battery(percent: power.batteryPercent, onBattery: power.isOnBattery)
        self.event = event.map { WebhookPayload($0, device: device, at: now) }
    }

    public func body() throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.sortedKeys]
        return try encoder.encode(self)
    }
}

/// The dashboard's reply. It carries a newer license key when one was issued (a renewal or a
/// seat change), so reporting Macs never need the key redeployed by hand.
public struct FleetReply: Codable, Equatable, Sendable {
    public var licenseKey: String?
}
