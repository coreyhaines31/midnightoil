import Foundation
import os

/// Owns the system-wide "disable sleep" switch (`pmset disablesleep`).
///
/// Safety rules:
/// - Sleep is disabled only while at least one app connection asks for it.
/// - A marker file is written before disabling and removed after re-enabling,
///   so if the helper itself dies mid-session, the next launch restores sleep.
final class SleepController: @unchecked Sendable {
    private static let logger = Logger(subsystem: "app.midnightoil.MidnightOil.Helper", category: "Sleep")
    private let markerURL = URL(filePath: "/Library/Application Support/Midnight Oil/sleep-disabled")
    // All state is confined to this serial queue.
    private let queue = DispatchQueue(label: "app.midnightoil.MidnightOil.Helper.sleep")
    private var holders = Set<ObjectIdentifier>()
    /// What pmset last succeeded at. Compared against instead of the old holder set, so a failed
    /// restore is retried on the next request or disconnect rather than forgotten.
    private var appliedDisabled = false

    func restoreIfLeftDisabled() {
        queue.sync {
            guard FileManager.default.fileExists(atPath: markerURL.path) else { return }
            Self.logger.notice("Found sleep left disabled by a previous run; restoring")
            // If that fails, sleep is still off: remember it so the next release retries.
            appliedDisabled = !apply(disabled: false)
        }
    }

    func setSleepDisabled(_ disabled: Bool, for holder: ObjectIdentifier) -> Bool {
        queue.sync {
            let isNewHolder = disabled && holders.insert(holder).inserted
            if !disabled { holders.remove(holder) }
            let shouldDisable = !holders.isEmpty
            guard shouldDisable != appliedDisabled else { return true }
            let succeeded = apply(disabled: shouldDisable)
            if succeeded {
                appliedDisabled = shouldDisable
            } else if isNewHolder {
                // The app gives up on closed-lid mode when this fails; don't keep a hold it dropped.
                holders.remove(holder)
            }
            return succeeded
        }
    }

    private func apply(disabled: Bool) -> Bool {
        if disabled {
            writeMarker()
            return runPmset(disabled: true)
        }
        let succeeded = runPmset(disabled: false)
        if succeeded { try? FileManager.default.removeItem(at: markerURL) }
        return succeeded
    }

    private func writeMarker() {
        let directory = markerURL.deletingLastPathComponent()
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        FileManager.default.createFile(atPath: markerURL.path, contents: nil)
    }

    private func runPmset(disabled: Bool) -> Bool {
        let process = Process()
        process.executableURL = URL(filePath: "/usr/bin/pmset")
        process.arguments = ["disablesleep", disabled ? "1" : "0"]
        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            Self.logger.error("pmset failed to launch: \(error.localizedDescription)")
            return false
        }
        Self.logger.notice("pmset disablesleep \(disabled ? 1 : 0) exited \(process.terminationStatus)")
        return process.terminationStatus == 0
    }
}
