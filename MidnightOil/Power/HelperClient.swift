import Foundation
import os
import ServiceManagement

/// Installs and talks to the privileged helper that keeps the Mac awake with the lid closed.
@MainActor
final class HelperClient {
    enum Status {
        case notInstalled
        case needsApproval
        case installed
    }

    private static let logger = Logger(subsystem: "app.midnightoil.MidnightOil", category: "Helper")
    private let service = SMAppService.daemon(plistName: HelperConstants.plistName)
    private var connection: NSXPCConnection?
    /// Called when the helper restarts mid-connection. It restores sleep on
    /// launch, so anything still wanted must be requested again.
    var onHelperRestarted: (() -> Void)?

    private static let registeredVersionKey = "helperRegisteredVersion"

    /// Re-registers an installed helper after an app update so launchd picks up
    /// any changes to the helper or its launchd plist.
    func refreshAfterUpdate() {
        guard status == .installed else { return }
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? ""
        let defaults = UserDefaults.standard
        guard defaults.string(forKey: Self.registeredVersionKey) != version else { return }
        do {
            try service.register()
            defaults.set(version, forKey: Self.registeredVersionKey)
            Self.logger.notice("Re-registered helper for build \(version, privacy: .public)")
        } catch {
            Self.logger.error("Helper re-registration failed: \(error.localizedDescription, privacy: .public)")
        }
    }

    var status: Status {
        switch service.status {
        case .enabled: .installed
        case .requiresApproval: .needsApproval
        case .notRegistered, .notFound: .notInstalled
        @unknown default: .notInstalled
        }
    }

    /// Registers the helper; macOS then asks for approval in System Settings › Login Items.
    func install() {
        do {
            try service.register()
        } catch where service.status == .requiresApproval {
            // Expected on first install: macOS won't start it until the user approves.
        } catch {
            Self.logger.error("Helper registration failed: \(error.localizedDescription, privacy: .public)")
        }
        if service.status == .requiresApproval {
            SMAppService.openSystemSettingsLoginItems()
        }
    }

    func uninstall() async {
        connection?.invalidate()
        connection = nil
        do {
            try await service.unregister()
        } catch {
            Self.logger.error("Helper removal failed: \(error.localizedDescription, privacy: .public)")
        }
    }

    /// Returns whether the helper applied the change.
    func setSleepDisabled(_ disabled: Bool) async -> Bool {
        guard status == .installed else { return false }
        let connection = currentConnection()
        return await withCheckedContinuation { continuation in
            let proxy = connection.remoteObjectProxyWithErrorHandler { error in
                Self.logger.error("Helper call failed: \(error.localizedDescription, privacy: .public)")
                continuation.resume(returning: false)
            }
            guard let helper = proxy as? HelperProtocol else {
                continuation.resume(returning: false)
                return
            }
            helper.setSleepDisabled(disabled) { applied in
                continuation.resume(returning: applied)
            }
        }
    }

    /// One long-lived connection: the helper restores sleep the moment it drops,
    /// which is what makes a crash or force-quit safe.
    private func currentConnection() -> NSXPCConnection {
        if let connection { return connection }
        let connection = NSXPCConnection(machServiceName: HelperConstants.machServiceName, options: .privileged)
        connection.remoteObjectInterface = NSXPCInterface(with: HelperProtocol.self)
        connection.setCodeSigningRequirement(HelperConstants.helperRequirement)
        connection.invalidationHandler = { [weak self] in
            Task { @MainActor in self?.connection = nil }
        }
        connection.interruptionHandler = { [weak self] in
            Task { @MainActor in self?.onHelperRestarted?() }
        }
        connection.resume()
        self.connection = connection
        return connection
    }
}
