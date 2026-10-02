import Foundation
import MidnightOilCore
import MidnightOilTeams
import os

/// Reports this Mac's state to the organization's fleet dashboard: a heartbeat every few
/// minutes and a report on every session start and end. Does nothing unless the license
/// includes the fleet dashboard and the organization's profile turns reporting on.
@MainActor
final class FleetReporter {
    private nonisolated static let logger = Logger(subsystem: "app.midnightoil.MidnightOil", category: "Fleet")
    private static let heartbeat: Duration = .seconds(5 * 60)

    private let license: TeamsLicense
    private let sessions: SessionController
    private let defaults: UserDefaults
    private var ticker: Task<Void, Never>?
    private var inFlight: [UUID: Task<Void, Never>] = [:]
    private nonisolated static let session = URLSession(
        configuration: .ephemeral, delegate: RefuseFleetRedirects(), delegateQueue: nil
    )

    init(license: TeamsLicense, sessions: SessionController, defaults: UserDefaults = .standard) {
        self.license = license
        self.sessions = sessions
        self.defaults = defaults
    }

    func start() {
        ticker = Task { [weak self] in
            // A first report soon after launch, then the regular heartbeat.
            try? await Task.sleep(for: .seconds(10))
            while !Task.isCancelled {
                guard let self else { return }
                self.report()
                try? await Task.sleep(for: Self.heartbeat)
            }
        }
    }

    func report(_ event: SessionEvent? = nil) {
        guard license.unlocks(.fleet), defaults.bool(forKey: TeamsSettingKey.fleetReporting),
              let key = license.key?.string
        else { return }
        let report = FleetReport(
            device: TeamsDeviceInfo.current(defaults: defaults),
            session: sessions.session,
            power: PowerSourceReader.current(),
            event: event
        )
        let endpoint = Self.endpoint(defaults: defaults)
        let id = UUID()
        inFlight[id] = Task.detached(priority: .utility) { [weak self] in
            let newKey = await Self.send(report, licenseKey: key, to: endpoint)
            await self?.finished(id, newKey: newKey)
        }
    }

    /// Lets the last report (the session ending on quit) go out before the app exits.
    func waitForReports(timeout: Duration) async {
        let deadline = ContinuousClock.now + timeout
        while !inFlight.isEmpty, ContinuousClock.now < deadline {
            try? await Task.sleep(for: .milliseconds(100))
        }
    }

    private func finished(_ id: UUID, newKey: String?) {
        inFlight[id] = nil
        // A renewed or resized key. A key the organization deployed can't be replaced here;
        // its profile carries the new one.
        if let newKey, newKey != license.key?.string, !license.isManaged {
            if let problem = license.activate(newKey) {
                let reason = String(describing: problem)
                Self.logger.error("Dashboard sent a key that didn't verify: \(reason, privacy: .public)")
            }
        }
    }

    private static func endpoint(defaults: UserDefaults) -> URL {
        #if DEBUG
        // Lets a development build report to a local copy of the dashboard.
        if let text = defaults.string(forKey: "fleetEndpoint"), let url = URL(string: text) { return url }
        #endif
        return URL(string: "https://app.midnightoil.app/api/v1/devices/report")!
    }

    /// Returns a newer license key if the dashboard sent one.
    private nonisolated static func send(_ report: FleetReport, licenseKey: String, to endpoint: URL) async -> String? {
        var request = URLRequest(url: endpoint, timeoutInterval: 15)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("License \(licenseKey)", forHTTPHeaderField: "Authorization")
        request.setValue("MidnightOil/\(report.device.appVersion)", forHTTPHeaderField: "User-Agent")
        do {
            request.httpBody = try report.body()
            let (data, response) = try await session.data(for: request)
            let status = (response as? HTTPURLResponse)?.statusCode ?? 0
            guard (200..<300).contains(status) else {
                logger.error("Fleet report rejected with \(status)")
                return nil
            }
            return try? JSONDecoder().decode(FleetReply.self, from: data).licenseKey
        } catch {
            logger.info("Fleet report failed: \(error.localizedDescription, privacy: .public)")
            return nil
        }
    }
}

private final class RefuseFleetRedirects: NSObject, URLSessionTaskDelegate {
    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        willPerformHTTPRedirection response: HTTPURLResponse,
        newRequest request: URLRequest
    ) async -> URLRequest? {
        nil
    }
}
