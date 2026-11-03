import Foundation
import WidgetKit

/// Answers the Control Center toggle and keeps it showing whether a session is running.
@MainActor
final class ControlCenterBridge {
    private let sessions: SessionController
    private var handledRequestID: String?

    init(sessions: SessionController) {
        self.sessions = sessions
    }

    func start() {
        // Requests made while the app wasn't running are stale; don't act on them at launch.
        handledRequestID = ControlBridge.latestRequest?.id
        let callback: CFNotificationCallback = { _, observer, _, _, _ in
            guard let observer else { return }
            let address = UInt(bitPattern: observer)
            DispatchQueue.main.async {
                MainActor.assumeIsolated {
                    guard let pointer = UnsafeRawPointer(bitPattern: address) else { return }
                    Unmanaged<ControlCenterBridge>.fromOpaque(pointer).takeUnretainedValue().handleRequest()
                }
            }
        }
        CFNotificationCenterAddObserver(
            CFNotificationCenterGetDarwinNotifyCenter(),
            Unmanaged.passUnretained(self).toOpaque(),
            callback,
            ControlBridge.requestNotification as CFString,
            nil,
            .deliverImmediately
        )
        publish()
    }

    /// Call whenever a session starts or ends.
    func publish() {
        ControlBridge.publish(isAwake: sessions.isActive)
        if #available(macOS 26.0, *) {
            ControlCenter.shared.reloadControls(ofKind: ControlBridge.controlKind)
        }
    }

    /// The write can land a moment after the notification, so look again a few times.
    private static let rechecks: [Duration] = [.milliseconds(300), .seconds(1), .seconds(3)]

    private func handleRequest(attempt: Int = 0) {
        // Any user's process can post the notification; only this user's extension can write
        // a new request to the app group.
        guard let request = ControlBridge.latestRequest, request.id != handledRequestID else {
            if attempt < Self.rechecks.count {
                Task {
                    try? await Task.sleep(for: Self.rechecks[attempt])
                    handleRequest(attempt: attempt + 1)
                }
            }
            return
        }
        handledRequestID = request.id
        if request.awake, !sessions.isActive {
            sessions.start(.indefinite)
        } else if !request.awake {
            sessions.end()
        }
        // The toggle flips before the app answers; set it right even when nothing changed.
        publish()
    }
}
