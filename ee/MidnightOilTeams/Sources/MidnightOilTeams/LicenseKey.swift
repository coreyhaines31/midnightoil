import CryptoKit
import Foundation

/// What a Midnight Oil for Teams license unlocks.
public enum TeamsFeature: String, Codable, Sendable, CaseIterable {
    case policies
    case webhook
    case fleet
}

/// The signed contents of a license key.
public struct LicensePayload: Codable, Equatable, Sendable {
    /// Format version.
    public var version: Int
    /// The organization's id in the Teams dashboard.
    public var org: String
    /// The organization's name, shown in Settings.
    public var name: String
    public var seats: Int
    /// The key stops working after this. Already includes the grace period after renewal is due.
    public var exp: Date
    public var features: [TeamsFeature]

    // Short keys keep license keys short.
    private enum CodingKeys: String, CodingKey {
        case version = "v", org, name, seats, exp, features
    }

    public init(version: Int = 1, org: String, name: String, seats: Int, exp: Date, features: [TeamsFeature]) {
        self.version = version
        self.org = org
        self.name = name
        self.seats = seats
        self.exp = exp
        self.features = features
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        version = try container.decode(Int.self, forKey: .version)
        org = try container.decode(String.self, forKey: .org)
        name = try container.decode(String.self, forKey: .name)
        seats = try container.decode(Int.self, forKey: .seats)
        exp = try container.decode(Date.self, forKey: .exp)
        // Skip features added after this version of the app, so newer keys still work here.
        features = try container.decode([String].self, forKey: .features).compactMap(TeamsFeature.init(rawValue:))
    }
}

/// A license key: `MO1-<base64url payload>.<base64url Ed25519 signature>`.
/// Verified offline against Midnight Oil's public key; nothing is sent anywhere.
public struct LicenseKey: Equatable, Sendable {
    public static let prefix = "MO1-"
    /// How long before expiry the app starts mentioning renewal.
    public static let renewalNotice: TimeInterval = 30 * 24 * 60 * 60

    public enum Problem: Error, Equatable, Sendable {
        case malformed
        case badSignature
        case unsupportedVersion
    }

    public enum Status: Equatable, Sendable {
        case valid
        case expiringSoon
        case expired
    }

    public let payload: LicensePayload
    public let string: String

    /// Parses and verifies a key. Throws if it's malformed or wasn't signed by `publicKey`.
    public init(_ text: String, publicKey: Curve25519.Signing.PublicKey) throws {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.hasPrefix(Self.prefix) else { throw Problem.malformed }
        let body = trimmed.dropFirst(Self.prefix.count)
        let parts = body.split(separator: ".", omittingEmptySubsequences: false)
        guard parts.count == 2,
              let payloadData = Base64URL.decode(String(parts[0])),
              let signature = Base64URL.decode(String(parts[1]))
        else { throw Problem.malformed }
        // The signature covers the encoded payload exactly as written in the key.
        guard publicKey.isValidSignature(signature, for: Data(parts[0].utf8)) else { throw Problem.badSignature }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let payload = try? decoder.decode(LicensePayload.self, from: payloadData) else { throw Problem.malformed }
        guard payload.version == 1 else { throw Problem.unsupportedVersion }
        self.payload = payload
        self.string = trimmed
    }

    public func status(at now: Date = .now) -> Status {
        if now >= payload.exp { return .expired }
        if payload.exp.timeIntervalSince(now) <= Self.renewalNotice { return .expiringSoon }
        return .valid
    }

    /// The key to use: a renewal fetched from the dashboard replaces the installed key only when
    /// it's for the same organization and runs later. Without an installed key there's nothing to renew.
    public static func current(installed: LicenseKey?, renewal: LicenseKey?) -> LicenseKey? {
        guard let installed else { return nil }
        guard let renewal, renewal.payload.org == installed.payload.org, renewal.payload.exp > installed.payload.exp
        else { return installed }
        return renewal
    }

    /// True while the key hasn't expired and includes `feature`.
    public func unlocks(_ feature: TeamsFeature, at now: Date = .now) -> Bool {
        status(at: now) != .expired && payload.features.contains(feature)
    }
}

enum Base64URL {
    static func decode(_ text: String) -> Data? {
        var base64 = text.replacingOccurrences(of: "-", with: "+").replacingOccurrences(of: "_", with: "/")
        base64 += String(repeating: "=", count: (4 - base64.count % 4) % 4)
        return Data(base64Encoded: base64)
    }

    static func encode(_ data: Data) -> String {
        data.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}
