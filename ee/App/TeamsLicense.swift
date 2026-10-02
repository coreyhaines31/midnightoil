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
    /// Renewals fetched from the dashboard. Kept apart from the installed key because a key
    /// deployed by a profile can't be overwritten by the app.
    static let renewalKey = "teamsRenewedLicenseKey"

    // Midnight Oil's license-signing public key. The private half signs keys in the Teams service.
    private static let publicKey: Curve25519.Signing.PublicKey = {
        let raw = Data(base64Encoded: "8Q6n8vf5geopiv31a4gGbh+PTBqXonc6fCq82maOV5k=") ?? Data()
        // A malformed constant is a build mistake; fail loudly rather than accept nothing.
        // swiftlint:disable:next force_try
        return try! Curve25519.Signing.PublicKey(rawRepresentation: raw)
    }()

    /// The key in use: the installed one, or a later renewal of it for the same organization.
    private(set) var key: LicenseKey?
    /// Why the installed key was rejected, if it was.
    private(set) var problem: LicenseKey.Problem?
    @ObservationIgnored private var installedText: String?
    @ObservationIgnored private var renewalText: String?

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
                guard let self else { return }
                self.reload()
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
        defaults.removeObject(forKey: Self.renewalKey)
        reload()
    }

    /// Stores a renewal the dashboard sent in reply to a report made with `presented`. Ignored if
    /// the key changed or was removed since that report, or if it isn't a later key for the same org.
    func adoptRenewal(_ text: String, inReplyTo presented: String) {
        guard key?.string == presented, let renewal = try? LicenseKey(text, publicKey: Self.publicKey),
              LicenseKey.current(installed: key, renewal: renewal) == renewal
        else { return }
        defaults.set(renewal.string, forKey: Self.renewalKey)
        reload()
    }

    private func reload() {
        let installed = defaults.string(forKey: Self.defaultsKey).flatMap { $0.isEmpty ? nil : $0 }
        let renewal = defaults.string(forKey: Self.renewalKey)
        guard installed != installedText || renewal != renewalText else { return }
        (installedText, renewalText) = (installed, renewal)

        var installedKey: LicenseKey?
        var newProblem: LicenseKey.Problem?
        if let installed {
            do {
                installedKey = try LicenseKey(installed, publicKey: Self.publicKey)
            } catch {
                newProblem = error as? LicenseKey.Problem ?? .malformed
            }
        }
        let renewalKey = renewal.flatMap { try? LicenseKey($0, publicKey: Self.publicKey) }
        let current = LicenseKey.current(installed: installedKey, renewal: renewalKey)
        // A renewal for a different or removed key is stale; drop it.
        if renewal != nil, current != renewalKey { defaults.removeObject(forKey: Self.renewalKey) }
        if current != key { key = current }
        if newProblem != problem { problem = newProblem }
    }
}
