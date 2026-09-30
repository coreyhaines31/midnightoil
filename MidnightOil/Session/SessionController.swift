import AppKit
import MidnightOilCore

enum SessionEndReason {
    case user
    case timeUp
    case lowBattery
    case appQuit(String)
}

/// Runs the current keep-awake session: holds the power assertions and ends the
/// session when its time is up or the battery runs low.
@MainActor
final class SessionController {
    private(set) var session: Session?
    /// Called whenever the session starts, ends, changes, or ticks.
    var onChange: (() -> Void)?

    private let assertions = AssertionManager()
    private var ticker: Task<Void, Never>?

    init() {
        // A sleeping Mac doesn't tick; re-check as soon as it wakes.
        NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didWakeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated { self?.tick() }
        }
    }

    var isActive: Bool { session != nil }

    func start(_ end: SessionEnd) {
        session = Session(start: .now, end: end, allowsDisplaySleep: Preferences.allowsDisplaySleep)
        applyAssertions()
        startTicker()
        onChange?()
    }

    func end(reason: SessionEndReason = .user) {
        guard session != nil else { return }
        session = nil
        ticker?.cancel()
        ticker = nil
        assertions.releaseAll()
        SessionNotifier.sessionEnded(reason)
        onChange?()
    }

    func extend(by interval: TimeInterval) {
        session = session?.extended(by: interval)
        onChange?()
    }

    func setAllowsDisplaySleep(_ allowed: Bool) {
        session?.allowsDisplaySleep = allowed
        applyAssertions()
        onChange?()
    }

    private func applyAssertions() {
        assertions.apply(keepAwake: session != nil, allowsDisplaySleep: session?.allowsDisplaySleep ?? true)
    }

    private func startTicker() {
        ticker?.cancel()
        ticker = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                self?.tick()
            }
        }
    }

    private func tick() {
        guard let session else { return }
        if let reason = endReason(for: session) {
            end(reason: reason)
        } else {
            onChange?()
        }
    }

    private func endReason(for session: Session) -> SessionEndReason? {
        if session.isFinished(at: .now) {
            return .timeUp
        }
        if case .whileAppRunning(let app) = session.end,
           NSRunningApplication.runningApplications(withBundleIdentifier: app.bundleIdentifier).isEmpty {
            return .appQuit(app.name)
        }
        if BatteryGuard.shouldEndSession(
            power: PowerSourceReader.current(),
            floorPercent: Preferences.batteryFloorPercent
        ) {
            return .lowBattery
        }
        return nil
    }
}
