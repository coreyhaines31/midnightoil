import CryptoKit
import Foundation
import MidnightOilTeams
import Observation

/// The Mac's Midnight Oil for Teams license. The key lives in UserDefaults, so an
/// organization can deploy it with a configuration profile instead of pasting it.
@MainActor
@Observable
final class TeamsLicense {
    static let defaultsKey = "teamsLicenseKey"

    // Midnight Oil's license-signing public key. The private half signs keys in the Teams service.
    private static let publicKey: Curve25519.Signing.PublicKey = {
        let raw = Data(base64Encoded: "8Q6n8vf5geopiv31a4gGbh+PTBqXonc6fCq82maOV5k=") ?? Data()
        // A malformed constant is a build mistake; fail loudly rather than accept nothing.
        // swiftlint:disable:next force_try
        return try! Curve25519.Signing.PublicKey(rawRepresentation: raw)
    }()

    private(set) var key: LicenseKey?
    /// Why the stored key was rejected, if it was.
    private(set) var problem: LicenseKey.Problem?

    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private var observer: NSObjectProtocol?
    @ObservationIgnored private var poller: Task<Void, Never>?

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        reload()
        // A profile can install or replace the key at any time.
        observer = NotificationCenter.default.addObserver(
            forName: UserDefaults.didChangeNotification, object: defaults, queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated { self?.reload() }
        }
        // Profiles are installed and removed outside the app, which posts no notification here.
        poller = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(10))
                self?.reload()
            }
        }
    }

    /// True when the key was deployed by the organization and can't be edited here.
    var isManaged: Bool { defaults.objectIsForced(forKey: Self.defaultsKey) }

    func unlocks(_ feature: TeamsFeature) -> Bool { key?.unlocks(feature) ?? false }

    /// Verifies and saves a pasted key. Returns the problem if it's rejected, and saves nothing.
    @discardableResult
    func activate(_ text: String) -> LicenseKey.Problem? {
        do {
            let verified = try LicenseKey(text, publicKey: Self.publicKey)
            defaults.set(verified.string, forKey: Self.defaultsKey)
            reload()
            return nil
        } catch {
            return error as? LicenseKey.Problem ?? .malformed
        }
    }

    func remove() {
        defaults.removeObject(forKey: Self.defaultsKey)
        reload()
    }

    private func reload() {
        guard let text = defaults.string(forKey: Self.defaultsKey), !text.isEmpty else {
            if key != nil || problem != nil { (key, problem) = (nil, nil) }
            return
        }
        guard text != key?.string else { return }
        do {
            key = try LicenseKey(text, publicKey: Self.publicKey)
            problem = nil
        } catch {
            key = nil
            problem = error as? LicenseKey.Problem ?? .malformed
        }
    }
}
