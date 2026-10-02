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
    /// When a session is expected to end, from its schedule or the organization's time limit.
    private let endsAt: @MainActor (Session) -> Date?
    private var ticker: Task<Void, Never>?
    private var lastReport: ContinuousClock.Instant?
    private var wasEnabled = false
    private var inFlight: [UUID: Task<Void, Never>] = [:]
    private nonisolated static let session = URLSession(
        configuration: .ephemeral, delegate: RefuseFleetRedirects(), delegateQueue: nil
    )

    init(
        license: TeamsLicense,
        sessions: SessionController,
        endsAt: @escaping @MainActor (Session) -> Date?,
        defaults: UserDefaults = .standard
    ) {
        self.license = license
        self.sessions = sessions
        self.endsAt = endsAt
        self.defaults = defaults
    }

    func start() {
        ticker = Task { [weak self] in
            try? await Task.sleep(for: .seconds(10))
            while !Task.isCancelled {
                guard let self else { return }
                self.heartbeatIfDue()
                // Checked often so a newly deployed profile shows up within a minute.
                try? await Task.sleep(for: .seconds(30))
            }
        }
    }

    private func heartbeatIfDue() {
        let enabled = isEnabled
        defer { wasEnabled = enabled }
        guard enabled else { return }
        let due = lastReport.map { ContinuousClock.now - $0 >= Self.heartbeat } ?? true
        if due || !wasEnabled { report() }
    }

    /// Reporting needs the profile's switch and a key that includes the fleet dashboard. An expired
    /// key still reports, so a Mac that was offline through a renewal can fetch the new key.
    private var isEnabled: Bool {
        defaults.bool(forKey: TeamsSettingKey.fleetReporting) && license.key?.payload.features.contains(.fleet) == true
    }

    func report(_ event: SessionEvent? = nil) {
        guard isEnabled, let key = license.key?.string else { return }
        lastReport = .now
        let session = sessions.session
        let report = FleetReport(
            device: TeamsDeviceInfo.current(defaults: defaults),
            session: session,
            endsAt: session.flatMap(endsAt),
            power: PowerSourceReader.current(),
            event: event
        )
        let endpoint = Self.endpoint(defaults: defaults)
        let id = UUID()
        inFlight[id] = Task.detached(priority: .utility) { [weak self] in
            let newKey = await Self.send(report, licenseKey: key, to: endpoint)
            await self?.finished(id, newKey: newKey, presented: key)
        }
    }

    /// Lets the last report (the session ending on quit) go out before the app exits.
    func waitForReports(timeout: Duration) async {
        let deadline = ContinuousClock.now + timeout
        while !inFlight.isEmpty, ContinuousClock.now < deadline {
            try? await Task.sleep(for: .milliseconds(100))
        }
    }

    private func finished(_ id: UUID, newKey: String?, presented: String) {
        inFlight[id] = nil
        // A renewed or resized key, kept only if the key this report used is still the one in use.
        if let newKey { license.adoptRenewal(newKey, inReplyTo: presented) }
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
