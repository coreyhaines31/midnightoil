import AppKit
import MidnightOilCore

enum SessionEndReason {
    case user
    case timeUp
    case lowBattery(floor: Int)
    case appQuit(String)
    case downloadFinished(String)
    case unplugged
    case triggerEnded(String)
    case scheduleEnded(String)
    /// A schedule's window is still open but one of its conditions stopped holding.
    case schedulePaused(String, condition: String)
    /// A manual session reached the organization's time limit.
    case policyLimit(TimeInterval)
    case replaced
    case quit

    var cause: SessionEndCause {
        switch self {
        case .user: .you
        case .timeUp: .timeUp
        case .lowBattery: .lowBattery
        case .appQuit: .appQuit
        case .downloadFinished: .downloadFinished
        case .unplugged: .unplugged
        case .triggerEnded: .triggerEnded
        case .scheduleEnded: .scheduleEnded
        case .schedulePaused: .schedulePaused
        case .policyLimit: .policyLimit
        case .replaced: .replaced
        case .quit: .midnightOilQuit
        }
    }
}

/// Runs the current keep-awake session: holds the power assertions and ends the
/// session when its time is up or the battery runs low.
@MainActor
final class SessionController {
    private(set) var session: Session?
    /// Called whenever the session starts, ends, changes, or ticks.
    var onChange: (() -> Void)?
    /// The organization's rules for sessions, from Midnight Oil for Teams. Read on every check,
    /// so a newly deployed profile applies right away.
    var policy: () -> SessionPolicy = { .none }
    /// Called when the user ends a session a trigger or schedule started, with its id.
    var onUserEndedAutomaticSession: ((UUID) -> Void)?

    let helper: HelperClient
    let history = SessionHistory()
    private let assertions = AssertionManager()
    /// What we last asked the helper for, so it's only messaged on changes.
    private var lidModeRequested = false
    private var lastLidClosed: Bool?
    private var ticker: Task<Void, Never>?
    private var download: DownloadProgress?
    private var lastPower: PowerState?
    private var tally: SessionTally?
    private var batteryAtStart: Int?

    init(helper: HelperClient) {
        self.helper = helper
        helper.onHelperRestarted = { [weak self] in
            guard let self else { return }
            lidModeRequested = false
            syncLidClosedMode()
        }
        let center = NSWorkspace.shared.notificationCenter
        // Count right up to sleep, then skip the time asleep entirely.
        center.addObserver(forName: NSWorkspace.willSleepNotification, object: nil, queue: .main) { [weak self] _ in
            MainActor.assumeIsolated { self?.sampleTally() }
        }
        // A sleeping Mac doesn't tick; re-check as soon as it wakes.
        center.addObserver(forName: NSWorkspace.didWakeNotification, object: nil, queue: .main) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.tally?.resumeAfterSleep(at: .now)
                self?.tick()
            }
        }
    }

    var isActive: Bool { session != nil }

    func start(_ end: SessionEnd) {
        begin(Session(
            start: .now,
            end: end,
            allowsDisplaySleep: Preferences.allowsDisplaySleep,
            staysAwakeWithLidClosed: Preferences.staysAwakeWithLidClosed && canUseLidMode
        ))
    }

    func start(trigger: Trigger) {
        begin(Session(
            start: .now,
            end: .indefinite,
            allowsDisplaySleep: trigger.allowsDisplaySleep,
            staysAwakeWithLidClosed: trigger.staysAwakeWithLidClosed && canUseLidMode,
            source: .trigger(id: trigger.id, name: trigger.name)
        ))
    }

    func start(schedule: AwakeSchedule) {
        begin(Session(
            start: .now,
            end: .indefinite,
            allowsDisplaySleep: schedule.allowsDisplaySleep,
            staysAwakeWithLidClosed: schedule.staysAwakeWithLidClosed && canUseLidMode,
            source: .schedule(id: schedule.id, name: schedule.name)
        ))
    }

    private func begin(_ newSession: Session) {
        if let previous = session {
            recordFinished(previous, reason: .replaced)
        }
        session = newSession
        tally = SessionTally(start: newSession.start)
        batteryAtStart = PowerSourceReader.current().batteryPercent
        switch newSession.source {
        case .trigger(_, let name): SessionNotifier.sessionStarted(byTrigger: name)
        case .schedule(_, let name): SessionNotifier.sessionStarted(bySchedule: name)
        case .manual: break
        }
        if case .whileDownloading(let file) = newSession.end {
            download = DownloadProgress(file: file, startedAt: .now)
        } else {
            download = nil
        }
        applyAssertions()
        syncLidClosedMode()
        startTicker()
        onChange?()
    }

    func end(reason: SessionEndReason = .user) {
        guard let session else { return }
        if case .user = reason, let id = session.source.automaticID {
            onUserEndedAutomaticSession?(id)
        }
        self.session = nil
        let record = recordFinished(session, reason: reason)
        tally = nil
        download = nil
        lastPower = nil
        lastLidClosed = nil
        ticker?.cancel()
        ticker = nil
        assertions.releaseAll()
        syncLidClosedMode()
        SessionNotifier.sessionEnded(reason, record: record)
        onChange?()
    }

    private func sampleTally() {
        guard let session else { return }
        tally?.sample(
            at: .now,
            idleSeconds: SystemStateReader.idleSeconds(),
            lidClosed: LidState.isClosed() ?? false,
            lidMode: session.staysAwakeWithLidClosed
        )
    }

    @discardableResult
    private func recordFinished(_ session: Session, reason: SessionEndReason) -> SessionRecord {
        // Count the time since the last tick, and a lid mode switched on just now.
        tally?.sample(
            at: .now,
            idleSeconds: SystemStateReader.idleSeconds(),
            lidClosed: LidState.isClosed() ?? false,
            lidMode: session.staysAwakeWithLidClosed
        )
        var triggerName: String?
        var scheduleName: String?
        switch session.source {
        case .trigger(_, let name): triggerName = name
        case .schedule(_, let name): scheduleName = name
        case .manual: break
        }
        var subject: String?
        switch session.end {
        case .whileAppRunning(let app): subject = app.name
        case .whileDownloading(let file): subject = DownloadProgress.displayName(for: file)
        case .indefinite, .after, .until: break
        }
        let record = SessionRecord(
            start: session.start,
            end: .now,
            triggerName: triggerName,
            scheduleName: scheduleName,
            endCause: reason.cause,
            subject: subject,
            awakeTime: tally?.awake,
            awayTime: tally?.away,
            lidClosedTime: tally?.lidClosed,
            usedLidMode: tally?.usedLidMode ?? session.staysAwakeWithLidClosed,
            batteryStart: batteryAtStart,
            batteryEnd: PowerSourceReader.current().batteryPercent
        )
        history.record(record)
        return record
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

    /// Closed-lid mode needs the helper, and an organization can switch it off.
    var canUseLidMode: Bool { helper.status == .installed && !policy().disallowsClosedLid }

    func setStaysAwakeWithLidClosed(_ staysAwake: Bool) {
        session?.staysAwakeWithLidClosed = staysAwake && !policy().disallowsClosedLid
        syncLidClosedMode()
        onChange?()
    }

    private func syncLidClosedMode() {
        let wanted = session?.staysAwakeWithLidClosed ?? false
        guard wanted != lidModeRequested else { return }
        lidModeRequested = wanted
        Task {
            let applied = await helper.setSleepDisabled(wanted)
            // If the helper couldn't do it, don't pretend the lid is covered.
            if wanted, !applied, lidModeRequested {
                lidModeRequested = false
                session?.staysAwakeWithLidClosed = false
                onChange?()
            }
        }
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
        sampleTally()
        // A profile deployed mid-session can switch closed-lid mode off.
        if session.staysAwakeWithLidClosed, policy().disallowsClosedLid {
            setStaysAwakeWithLidClosed(false)
        }
        if let reason = endReason(for: session) {
            end(reason: reason)
        } else {
            soundLidAlarmIfNeeded(for: session)
            onChange?()
        }
    }

    private func soundLidAlarmIfNeeded(for session: Session) {
        guard session.staysAwakeWithLidClosed, Preferences.soundsLidAlarm else { return }
        let isClosed = LidState.isClosed() ?? false
        defer { lastLidClosed = isClosed }
        let isOnBattery = lastPower?.isOnBattery ?? false
        if LidAlarm.shouldSound(wasClosed: lastLidClosed, isClosed: isClosed, isOnBattery: isOnBattery) {
            SystemSounds.play(Preferences.lidAlarmSound)
        }
    }

    /// Checks every way the session can end. Not pure: it also advances the
    /// download watcher, so call it once per tick.
    private func endReason(for session: Session) -> SessionEndReason? {
        if session.isFinished(at: .now) {
            return .timeUp
        }
        let policy = policy()
        if policy.isOverLimit(session, at: .now), let limit = policy.maxManualSession {
            return .policyLimit(limit)
        }
        if case .whileAppRunning(let app) = session.end,
           NSRunningApplication.runningApplications(withBundleIdentifier: app.bundleIdentifier).isEmpty {
            return .appQuit(app.name)
        }
        if case .whileDownloading(let file) = session.end, !advanceDownload(file) {
            return .downloadFinished(DownloadProgress.displayName(for: file))
        }
        let power = PowerSourceReader.current()
        defer { lastPower = power }
        if Preferences.endsWhenUnplugged, BatteryGuard.wasUnplugged(from: lastPower, to: power) {
            return .unplugged
        }
        let floor = policy.batteryFloor(user: Preferences.batteryFloorPercent)
        if let floor, BatteryGuard.shouldEndSession(power: power, floorPercent: floor) {
            return .lowBattery(floor: floor)
        }
        return nil
    }

    /// Returns whether the file is still downloading.
    private func advanceDownload(_ file: URL) -> Bool {
        guard var progress = download else { return false }
        // Browser partial files only need to exist; skip sizing Safari's package every second.
        let size = progress.isPartialFile
            ? (FileManager.default.fileExists(atPath: file.path) ? 0 : nil)
            : FileSizeReader.size(of: file)
        let stillDownloading = progress.update(size: size, at: .now)
        download = progress
        return stillDownloading
    }
}
