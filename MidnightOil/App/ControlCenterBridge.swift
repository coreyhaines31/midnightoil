import Foundation
import WidgetKit

/// Answers the Control Center toggle and keeps it showing whether a session is running.
@MainActor
final class ControlCenterBridge {
    private let sessions: SessionController

    init(sessions: SessionController) {
        self.sessions = sessions
    }

    func start() {
        let callback: CFNotificationCallback = { _, observer, name, _, _ in
            guard let observer, let name else { return }
            let address = UInt(bitPattern: observer)
            let starts = name.rawValue as String == ControlBridge.startNotification
            DispatchQueue.main.async {
                MainActor.assumeIsolated {
                    guard let pointer = UnsafeRawPointer(bitPattern: address) else { return }
                    Unmanaged<ControlCenterBridge>.fromOpaque(pointer).takeUnretainedValue().handle(starts: starts)
                }
            }
        }
        let center = CFNotificationCenterGetDarwinNotifyCenter()
        let observer = Unmanaged.passUnretained(self).toOpaque()
        for name in [ControlBridge.startNotification, ControlBridge.stopNotification] {
            CFNotificationCenterAddObserver(center, observer, callback, name as CFString, nil, .deliverImmediately)
        }
        publish()
    }

    /// Call whenever a session starts or ends.
    func publish() {
        ControlBridge.defaults?.set(sessions.isActive, forKey: ControlBridge.isAwakeKey)
        if #available(macOS 26.0, *) {
            ControlCenter.shared.reloadControls(ofKind: ControlBridge.controlKind)
        }
    }

    private func handle(starts: Bool) {
        if starts, !sessions.isActive {
            sessions.start(.indefinite)
        } else if !starts {
            sessions.end()
        }
        // The toggle flips before the app answers; set it right even when nothing changed.
        publish()
    }
}
