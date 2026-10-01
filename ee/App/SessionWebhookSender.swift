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
    /// Never follows redirects: a redirect could send the signed body somewhere the profile didn't name.
    private nonisolated static let session = URLSession(
        configuration: .ephemeral, delegate: RefuseRedirects(), delegateQueue: nil
    )

    init(license: TeamsLicense, defaults: UserDefaults = .standard) {
        self.license = license
        self.defaults = defaults
    }

    func send(_ event: SessionEvent) {
        guard license.unlocks(.webhook),
              let text = defaults.string(forKey: TeamsSettingKey.webhookURL),
              let url = URL(string: text), Self.isAllowed(url)
        else { return }
        let payload = WebhookPayload(event, device: TeamsDeviceInfo.current(defaults: defaults))
        let secret = defaults.string(forKey: TeamsSettingKey.webhookSecret)
        Task.detached(priority: .utility) {
            await Self.deliver(payload, to: url, secret: secret)
        }
    }

    /// https anywhere, or plain http to this Mac itself (a local relay or a test receiver).
    nonisolated static func isAllowed(_ url: URL) -> Bool {
        switch url.scheme {
        case "https": true
        case "http": ["localhost", "127.0.0.1", "::1"].contains(url.host ?? "")
        default: false
        }
    }

    private nonisolated static func deliver(_ payload: WebhookPayload, to url: URL, secret: String?) async {
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
            if delay > 0 { try? await Task.sleep(for: .seconds(delay)) }
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
