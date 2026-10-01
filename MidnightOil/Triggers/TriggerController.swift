import Foundation
import MidnightOilCore

/// Evaluates schedules and triggers on a timer and starts or ends their sessions.
/// Manual sessions always win, then schedules, then triggers. A session the user
/// ends by hand stays off until its schedule or trigger stops matching.
@MainActor
final class TriggerController {
    private static let interval: Duration = .seconds(5)

    private let store: TriggerStore
    private let schedules: ScheduleStore
    private let sessions: SessionController
    /// Schedules and triggers the user ended by hand, quiet until they stop matching.
    private var suppressed: Set<UUID> = []
    private var ticker: Task<Void, Never>?

    init(store: TriggerStore, schedules: ScheduleStore, sessions: SessionController) {
        self.store = store
        self.schedules = schedules
        self.sessions = sessions
        sessions.onUserEndedAutomaticSession = { [weak self] id in
            self?.suppressed.insert(id)
        }
        store.onChange = { [weak self] in self?.evaluate() }
        schedules.onChange = { [weak self] in self?.evaluate() }
        ticker = Task { [weak self] in
            while !Task.isCancelled {
                self?.evaluate()
                try? await Task.sleep(for: Self.interval)
            }
        }
    }

    func evaluate() {
        let enabledSchedules = schedules.schedules.filter(\.isEnabled)
        let triggers = Preferences.triggersEnabled ? store.triggers.filter(\.isEnabled) : []
        // Schedules come first, so one wins over a trigger that matches at the same time.
        let candidates = enabledSchedules.map(\.asTrigger) + triggers
        let needs = Self.needs(for: triggers)
        if needs.wifi { WifiAccess.requestIfNeeded() }
        let state = SystemStateReader.current(needs: needs)

        suppressed = TriggerEngine.stillSuppressed(suppressed, triggers: candidates, state: state)
        let source = sessions.session?.source
        let running = source?.automaticID
        let active = TriggerEngine.activeTrigger(in: candidates, state: state, suppressed: suppressed, running: running)

        switch (source, active) {
        case (.manual?, _), (nil, nil):
            return
        case (_, let active?) where active.id == running:
            return
        case (_, let active?):
            if let schedule = enabledSchedules.first(where: { $0.id == active.id }) {
                sessions.start(schedule: schedule)
            } else {
                sessions.start(trigger: active)
            }
        case (.trigger(_, let name)?, nil):
            sessions.end(reason: .triggerEnded(name))
        case (.schedule(_, let name)?, nil):
            sessions.end(reason: .scheduleEnded(name))
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
