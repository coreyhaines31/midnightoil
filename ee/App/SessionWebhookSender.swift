import Foundation
import MidnightOilCore
import MidnightOilTeams
import os

/// Posts session events to the webhook URL in the organization's profile. Does nothing
/// without a license that includes webhooks, or without an https (or local http) URL.
@MainActor
final class SessionWebhookSender {
    private nonisolated static let logger = Logger(subsystem: "app.midnightoil.MidnightOil", category: "Webhook")
    /// Seconds to wait before each retry. A delivery that still fails is dropped.
    private nonisolated static let retryDelays: [UInt64] = [2, 10, 60]

    private let license: TeamsLicense
    private let defaults: UserDefaults
    /// When a session is expected to end, from its schedule or the organization's time limit.
    private let endsAt: @MainActor (Session) -> Date?
    private var inFlight: [UUID: Task<Void, Never>] = [:]
    /// Never follows redirects: a redirect could send the signed body somewhere the profile didn't name.
    private nonisolated static let session = URLSession(
        configuration: .ephemeral, delegate: RefuseRedirects(), delegateQueue: nil
    )

    init(license: TeamsLicense, endsAt: @escaping @MainActor (Session) -> Date?, defaults: UserDefaults = .standard) {
        self.license = license
        self.endsAt = endsAt
        self.defaults = defaults
    }

    /// The configured URL, if sending is allowed right now.
    private var destination: URL? {
        guard license.unlocks(.webhook), let text = defaults.string(forKey: TeamsSettingKey.webhookURL),
              let url = URL(string: text), Self.isAllowed(url)
        else { return nil }
        return url
    }

    func send(_ event: SessionEvent) {
        guard let url = destination else { return }
        let session: Session = switch event {
        case .started(let session), .ended(let session, _): session
        }
        let device = TeamsDeviceInfo.current(defaults: defaults)
        let payload = WebhookPayload(event, device: device, endsAt: endsAt(session))
        let secret = defaults.string(forKey: TeamsSettingKey.webhookSecret)
        let id = UUID()
        // Each retry first checks the license and URL haven't been removed or changed since.
        let stillWanted: @Sendable () async -> Bool = { [weak self] in await self?.destination == url }
        inFlight[id] = Task.detached(priority: .utility) { [weak self] in
            await Self.deliver(payload, to: url, secret: secret, stillWanted: stillWanted)
            await self?.finished(id)
        }
    }

    /// Lets the last event (usually `session.ended` on quit) go out before the app exits.
    func waitForDeliveries(timeout: Duration) async {
        let deadline = ContinuousClock.now + timeout
        while !inFlight.isEmpty, ContinuousClock.now < deadline {
            try? await Task.sleep(for: .milliseconds(100))
        }
    }

    private func finished(_ id: UUID) {
        inFlight[id] = nil
    }

    /// https anywhere, or plain http to this Mac itself (a local relay or a test receiver).
    nonisolated static func isAllowed(_ url: URL) -> Bool {
        switch url.scheme {
        case "https": true
        case "http": ["localhost", "127.0.0.1", "::1"].contains(url.host ?? "")
        default: false
        }
    }

    private nonisolated static func deliver(
        _ payload: WebhookPayload,
        to url: URL,
        secret: String?,
        stillWanted: @Sendable () async -> Bool
    ) async {
        var request = URLRequest(url: url, timeoutInterval: 10)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("MidnightOil/\(payload.device.appVersion)", forHTTPHeaderField: "User-Agent")
        do {
            if SessionWebhook.isSlack(url) {
                request.httpBody = try JSONEncoder().encode(["text": SessionWebhook.slackText(for: payload)])
            } else {
                let body = try SessionWebhook.body(for: payload)
                request.httpBody = body
                if let secret, !secret.isEmpty {
                    let signature = SessionWebhook.signature(body: body, secret: secret)
                    request.setValue(signature, forHTTPHeaderField: SessionWebhook.signatureHeader)
                }
            }
        } catch {
            logger.error("Couldn't encode webhook: \(error.localizedDescription, privacy: .public)")
            return
        }
        for (attempt, delay) in ([0] + retryDelays).enumerated() {
            if delay > 0 {
                try? await Task.sleep(for: .seconds(delay))
                guard await stillWanted() else { return }
            }
            do {
                let (_, response) = try await session.data(for: request)
                let status = (response as? HTTPURLResponse)?.statusCode ?? 0
                if (200..<300).contains(status) { return }
                // Redirects are refused, and 4xx other than 429 won't get better by retrying.
                if (300..<500).contains(status), status != 429 {
                    logger.error("Webhook rejected with \(status)")
                    return
                }
            } catch {
                logger.info("Webhook attempt \(attempt + 1) failed: \(error.localizedDescription, privacy: .public)")
            }
        }
        logger.error("Gave up delivering \(payload.event, privacy: .public) \(payload.id, privacy: .public)")
    }
}

private final class RefuseRedirects: NSObject, URLSessionTaskDelegate {
    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        willPerformHTTPRedirection response: HTTPURLResponse,
        newRequest request: URLRequest
    ) async -> URLRequest? {
        nil
    }
}
