import Foundation
import MidnightOilCore

/// Evaluates triggers on a timer and starts or ends trigger sessions.
/// Manual sessions always win; a trigger session the user ends by hand stays
/// off until that trigger's criteria stop matching.
@MainActor
final class TriggerController {
    private static let interval: Duration = .seconds(5)

    private let store: TriggerStore
    private let sessions: SessionController
    private var suppressed: UUID?
    private var ticker: Task<Void, Never>?

    init(store: TriggerStore, sessions: SessionController) {
        self.store = store
        self.sessions = sessions
        sessions.onUserEndedTriggerSession = { [weak self] id in
            self?.suppressed = id
        }
        store.onChange = { [weak self] in self?.evaluate() }
        ticker = Task { [weak self] in
            while !Task.isCancelled {
                self?.evaluate()
                try? await Task.sleep(for: Self.interval)
            }
        }
    }

    func evaluate() {
        let triggers = Preferences.triggersEnabled ? store.triggers.filter(\.isEnabled) : []
        let needs = Self.needs(for: triggers)
        if needs.wifi { WifiAccess.requestIfNeeded() }
        let state = SystemStateReader.current(needs: needs)

        if TriggerEngine.canRearm(suppressed, triggers: triggers, state: state) {
            suppressed = nil
        }
        let active = TriggerEngine.activeTrigger(in: triggers, state: state, suppressed: suppressed)

        switch (sessions.session?.source, active) {
        case (.manual?, _), (nil, nil):
            return
        case (.trigger(let id, _)?, let active?) where active.id == id:
            return
        case (.trigger?, let active?), (nil, let active?):
            sessions.start(trigger: active)
        case (.trigger(_, let name)?, nil):
            sessions.end(reason: .triggerEnded(name))
        }
    }

    private static func needs(for triggers: [Trigger]) -> SystemStateReader.Needs {
        var needs = SystemStateReader.Needs()
        for criterion in triggers.flatMap(\.criteria) {
            switch criterion {
            case .wifiNetwork: needs.wifi = true
            case .usbDevice: needs.usb = true
            case .bluetoothDevice: needs.bluetooth = true
            default: break
            }
        }
        return needs
    }
}
