import Foundation

public enum RemainingTime {
    /// Compact countdown like "1h 05m", "23m", or "<1m". Minutes round up so a
    /// fresh 25-minute session reads "25m", not "24m".
    public static func short(_ interval: TimeInterval) -> String {
        let totalMinutes = Int((interval / 60).rounded(.up))
        if interval < 60 { return "<1m" }
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        if hours == 0 { return "\(minutes)m" }
        return minutes == 0 ? "\(hours)h" : "\(hours)h " + String(format: "%02dm", minutes)
    }

    /// Precise countdown for the open menu, like "1d 14h 05m 20s", "1h 05m 20s", "10m 20s", or "45s".
    public static func detailed(_ interval: TimeInterval) -> String {
        let totalSeconds = max(0, Int(interval.rounded(.down)))
        let days = totalSeconds / 86_400
        if days > 0 {
            let rest = totalSeconds % 86_400
            return "\(days)d " + String(format: "%02dh %02dm %02ds", rest / 3_600, rest % 3_600 / 60, rest % 60)
        }
        let hours = totalSeconds / 3_600
        let minutes = totalSeconds % 3_600 / 60
        let seconds = totalSeconds % 60
        if hours > 0 { return "\(hours)h " + String(format: "%02dm %02ds", minutes, seconds) }
        if minutes > 0 { return "\(minutes)m " + String(format: "%02ds", seconds) }
        return "\(seconds)s"
    }
}
