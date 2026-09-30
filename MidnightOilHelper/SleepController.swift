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

    func restoreIfLeftDisabled() {
        queue.sync {
            guard FileManager.default.fileExists(atPath: markerURL.path) else { return }
            Self.logger.notice("Found sleep left disabled by a previous run; restoring")
            _ = apply(disabled: false)
        }
    }

    func setSleepDisabled(_ disabled: Bool, for holder: ObjectIdentifier) -> Bool {
        queue.sync {
            let wasDisabled = !holders.isEmpty
            if disabled {
                holders.insert(holder)
            } else {
                holders.remove(holder)
            }
            let shouldDisable = !holders.isEmpty
            guard shouldDisable != wasDisabled else { return true }
            return apply(disabled: shouldDisable)
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
