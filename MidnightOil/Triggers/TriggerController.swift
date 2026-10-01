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
        let scheduleTriggers = enabledSchedules.map(\.asTrigger)
        let triggers = Preferences.triggersEnabled ? store.triggers.filter(\.isEnabled) : []
        let needs = Self.needs(for: scheduleTriggers + triggers)
        if needs.wifi { WifiAccess.requestIfNeeded() }
        let state = SystemStateReader.current(needs: needs)

        suppressed = TriggerEngine.stillSuppressed(suppressed, triggers: scheduleTriggers + triggers, state: state)
        let source = sessions.session?.source
        let running = source?.automaticID
        // A matching schedule always beats a trigger; within each, the running one stays.
        func active(in list: [Trigger]) -> Trigger? {
            TriggerEngine.activeTrigger(in: list, state: state, suppressed: suppressed, running: running)
        }
        let active = active(in: scheduleTriggers) ?? active(in: triggers)

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
        case (.schedule(let id, let name)?, nil):
            sessions.end(reason: Self.reason(endingSchedule: id, named: name, in: enabledSchedules, state: state))
        }
    }

    /// Paused if the window is still open and a condition failed; otherwise over.
    private static func reason(
        endingSchedule id: UUID,
        named name: String,
        in schedules: [AwakeSchedule],
        state: SystemState
    ) -> SessionEndReason {
        guard let schedule = schedules.first(where: { $0.id == id }),
              Criterion.schedule(schedule.schedule).matches(state),
              let failed = schedule.conditions.first(where: { !$0.matches(state) })
        else { return .scheduleEnded(name) }
        return .schedulePaused(name, condition: failed.summary)
    }

    static func needs(for triggers: [Trigger]) -> SystemStateReader.Needs {
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
