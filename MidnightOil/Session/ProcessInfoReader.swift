import Darwin
import Foundation
import MidnightOilCore

/// Looks up processes a session waits on.
enum ProcessInfoReader {
    /// When a process started, or nil if it's gone or can't be read.
    static func startTime(of pid: Int32) -> Date? {
        var info = proc_bsdinfo()
        let size = Int32(MemoryLayout<proc_bsdinfo>.size)
        guard proc_pidinfo(pid, PROC_PIDTBSDINFO, 0, &info, size) == size else { return nil }
        return Date(timeIntervalSince1970: TimeInterval(info.pbi_start_tvsec)
            + TimeInterval(info.pbi_start_tvusec) / 1_000_000)
    }

    /// Whether the process is still the one we started watching, not a later one with its PID.
    static func isRunning(_ process: WatchedProcess) -> Bool {
        guard let started = process.started else {
            // EPERM means it exists but belongs to someone else.
            return kill(process.pid, 0) == 0 || errno == EPERM
        }
        return startTime(of: process.pid) == started
    }
}
