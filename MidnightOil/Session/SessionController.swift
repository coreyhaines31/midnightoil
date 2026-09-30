import AppKit
import MidnightOilCore

enum SessionEndReason {
    case user
    case timeUp
    case lowBattery
    case appQuit(String)
    case downloadFinished(String)
    case unplugged
}

/// Runs the current keep-awake session: holds the power assertions and ends the
/// session when its time is up or the battery runs low.
@MainActor
final class SessionController {
    private(set) var session: Session?
    /// Called whenever the session starts, ends, changes, or ticks.
    var onChange: (() -> Void)?

    let helper: HelperClient
    private let assertions = AssertionManager()
    /// What we last asked the helper for, so it's only messaged on changes.
    private var lidModeRequested = false
    private var lastLidClosed: Bool?
    private var ticker: Task<Void, Never>?
    private var download: DownloadProgress?
    private var lastPower: PowerState?

    init(helper: HelperClient) {
        self.helper = helper
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
        session = Session(
            start: .now,
            end: end,
            allowsDisplaySleep: Preferences.allowsDisplaySleep,
            staysAwakeWithLidClosed: Preferences.staysAwakeWithLidClosed && helper.status == .installed
        )
        if case .whileDownloading(let file) = end {
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
        guard session != nil else { return }
        session = nil
        download = nil
        lastPower = nil
        lastLidClosed = nil
        ticker?.cancel()
        ticker = nil
        assertions.releaseAll()
        syncLidClosedMode()
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

    func setStaysAwakeWithLidClosed(_ staysAwake: Bool) {
        session?.staysAwakeWithLidClosed = staysAwake
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
            NSSound(named: "Sosumi")?.play()
        }
    }

    /// Checks every way the session can end. Not pure: it also advances the
    /// download watcher, so call it once per tick.
    private func endReason(for session: Session) -> SessionEndReason? {
        if session.isFinished(at: .now) {
            return .timeUp
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
        if BatteryGuard.shouldEndSession(power: power, floorPercent: Preferences.batteryFloorPercent) {
            return .lowBattery
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
