import CryptoKit
import Foundation
@testable import MidnightOilTeams
import Testing

struct LicenseKeyTests {
    let signer = Curve25519.Signing.PrivateKey()

    func payload(exp: Date, features: [TeamsFeature] = TeamsFeature.allCases) -> LicensePayload {
        LicensePayload(org: "org_1", name: "Acme", seats: 10, exp: exp, features: features)
    }

    /// Signs the way the cloud app does: the signature covers the encoded payload text.
    func sign(_ payload: LicensePayload, with key: Curve25519.Signing.PrivateKey? = nil) throws -> String {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let body = Base64URL.encode(try encoder.encode(payload))
        let signature = try (key ?? signer).signature(for: Data(body.utf8))
        return LicenseKey.prefix + body + "." + Base64URL.encode(signature)
    }

    @Test func aSignedKeyVerifies() throws {
        let exp = Date(timeIntervalSince1970: 2_000_000_000)
        let key = try LicenseKey(try sign(payload(exp: exp)), publicKey: signer.publicKey)
        #expect(key.payload.name == "Acme")
        #expect(key.payload.seats == 10)
        #expect(key.payload.exp == exp)
    }

    @Test func surroundingWhitespaceFromAPasteIsIgnored() throws {
        let text = "  \n" + (try sign(payload(exp: .distantFuture))) + "\n"
        #expect(throws: Never.self) { try LicenseKey(text, publicKey: signer.publicKey) }
    }

    @Test func aKeyFromAnotherSignerIsRejected() throws {
        let other = Curve25519.Signing.PrivateKey()
        let text = try sign(payload(exp: .distantFuture), with: other)
        #expect(throws: LicenseKey.Problem.badSignature) { try LicenseKey(text, publicKey: signer.publicKey) }
    }

    @Test func editingThePayloadBreaksTheSignature() throws {
        let original = try sign(payload(exp: .distantFuture))
        let body = original.dropFirst(LicenseKey.prefix.count).split(separator: ".")
        var forged = payload(exp: .distantFuture)
        forged.seats = 10_000
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let forgedBody = Base64URL.encode(try encoder.encode(forged))
        let text = LicenseKey.prefix + forgedBody + "." + body[1]
        #expect(throws: LicenseKey.Problem.badSignature) { try LicenseKey(text, publicKey: signer.publicKey) }
    }

    @Test func garbageIsMalformed() {
        for text in ["", "hello", "MO1-", "MO1-abc", "MO1-abc.def.ghi", "MO2-abc.def"] {
            #expect(throws: (any Error).self) { try LicenseKey(text, publicKey: signer.publicKey) }
        }
    }

    @Test func statusWarnsBeforeExpiryAndStopsAfter() throws {
        let exp = Date(timeIntervalSince1970: 2_000_000_000)
        let key = try LicenseKey(try sign(payload(exp: exp)), publicKey: signer.publicKey)
        #expect(key.status(at: exp.addingTimeInterval(-60 * 24 * 3_600)) == .valid)
        #expect(key.status(at: exp.addingTimeInterval(-10 * 24 * 3_600)) == .expiringSoon)
        #expect(key.status(at: exp) == .expired)
    }

    @Test func featuresUnlockOnlyWhileValid() throws {
        let exp = Date(timeIntervalSince1970: 2_000_000_000)
        let key = try LicenseKey(try sign(payload(exp: exp, features: [.webhook])), publicKey: signer.publicKey)
        #expect(key.unlocks(.webhook, at: exp.addingTimeInterval(-1)))
        #expect(!key.unlocks(.fleet, at: exp.addingTimeInterval(-1)))
        #expect(!key.unlocks(.webhook, at: exp))
    }

    @Test func featuresFromANewerKeyAreSkipped() throws {
        let json = #"{"v":1,"org":"o","name":"Acme","seats":5,"exp":"2030-01-01T00:00:00Z","features":["fleet","sso"]}"#
        let body = Base64URL.encode(Data(json.utf8))
        let text = LicenseKey.prefix + body + "." + Base64URL.encode(try signer.signature(for: Data(body.utf8)))
        let key = try LicenseKey(text, publicKey: signer.publicKey)
        #expect(key.payload.features == [.fleet])
    }

    @Test func aRenewalReplacesTheInstalledKeyOnlyForTheSameOrgAndALaterDate() throws {
        func key(org: String, exp: TimeInterval) throws -> LicenseKey {
            var payload = payload(exp: Date(timeIntervalSince1970: exp))
            payload.org = org
            return try LicenseKey(try sign(payload), publicKey: signer.publicKey)
        }
        let installed = try key(org: "a", exp: 2_000_000_000)
        let later = try key(org: "a", exp: 2_100_000_000)
        #expect(LicenseKey.current(installed: installed, renewal: later) == later)
        #expect(LicenseKey.current(installed: later, renewal: installed) == later)
        #expect(LicenseKey.current(installed: installed, renewal: try key(org: "b", exp: 2_100_000_000)) == installed)
        #expect(LicenseKey.current(installed: nil, renewal: later) == nil)
    }

    @Test func aSeatChangeWithTheSameExpiryReplacesTheKeyByIssueDate() throws {
        func key(seats: Int, issued: TimeInterval) throws -> LicenseKey {
            var payload = payload(exp: Date(timeIntervalSince1970: 2_000_000_000))
            payload.seats = seats
            payload.iat = Date(timeIntervalSince1970: issued)
            return try LicenseKey(try sign(payload), publicKey: signer.publicKey)
        }
        let five = try key(seats: 5, issued: 1_900_000_000)
        let twenty = try key(seats: 20, issued: 1_900_100_000)
        #expect(LicenseKey.current(installed: five, renewal: twenty) == twenty)
        #expect(LicenseKey.current(installed: twenty, renewal: five) == twenty)
    }

    /// Signed by Node's crypto with a throwaway key, exactly as the cloud app signs.
    /// Guards the format both sides must agree on (no fractional seconds in `exp`).
    @Test func aKeySignedByTheCloudAppVerifies() throws {
        let publicKey = try Curve25519.Signing.PublicKey(
            rawRepresentation: Data(base64Encoded: "oXoofbpXJ6rHg6PBL3BGMLz2FUrFEy+Fg7ndIa0iSh8=") ?? Data()
        )
        let text = "MO1-"
            + "eyJ2IjoxLCJvcmciOiJvcmdfdGVzdCIsIm5hbWUiOiJBY21lLCBJbmMuIiwic2VhdHMiOjEyLCJleHAiOiIy"
            + "MDMwLTAxLTAxVDAwOjAwOjAwWiIsImZlYXR1cmVzIjpbInBvbGljaWVzIiwid2ViaG9vayIsImZsZWV0Il19"
            + ".FXWNPqpv4ZI_Yp_3DR2GikwjUyPbHuvVp6j-zWwRENMey-TrZG2aKgBBuytVlv_q7_xrdvkOiyT1a1AGzeLLBA"
        let key = try LicenseKey(text, publicKey: publicKey)
        #expect(key.payload.name == "Acme, Inc.")
        #expect(key.payload.seats == 12)
        #expect(key.payload.features == [.policies, .webhook, .fleet])
    }

    /// The cloud app's current format, with the issue date, signed by Node with a throwaway key.
    @Test func aCloudKeyWithAnIssueDateVerifies() throws {
        let publicKey = try Curve25519.Signing.PublicKey(
            rawRepresentation: Data(base64Encoded: "+DHNy1JXdbQ4Q9m6T/FxE8+73BNtSwVqPHdNfia69Mk=") ?? Data()
        )
        let text = "MO1-"
            + "eyJ2IjoxLCJvcmciOiJvcmdfdGVzdCIsIm5hbWUiOiJBY21lIiwic2VhdHMiOjIwLCJleHAiOiIyMDMwLTAx"
            + "LTAxVDAwOjAwOjAwWiIsImZlYXR1cmVzIjpbInBvbGljaWVzIiwid2ViaG9vayIsImZsZWV0Il0sImlhdCI6"
            + "IjIwMjktMDYtMDFUMTI6MDA6MDBaIn0"
            + ".zpwPb-jfe6y6Z1csGw899HzxDEpVJxcWvfZ4oMZLnFjHaLLkN_sfxIsOf7jAMaEbGjyPAgng6mMy4FMOweYuAw"
        let key = try LicenseKey(text, publicKey: publicKey)
        #expect(key.payload.seats == 20)
        #expect(key.payload.iat == Date(timeIntervalSince1970: 1_875_009_600))
    }
}
