import Foundation

/// Session history as CSV, for people who want the raw numbers.
public enum SessionCSV {
    public static let header = [
        "start", "end", "awake_minutes", "away_minutes", "lid_closed_minutes",
        "ended_because", "subject", "trigger", "battery_start", "battery_end",
        "schedule"
    ]

    public static func make(_ records: [SessionRecord]) -> String {
        let iso = ISO8601DateFormatter()
        let rows = records.map { record in
            [
                iso.string(from: record.start),
                iso.string(from: record.end),
                minutes(record.awake),
                minutes(record.away),
                record.lidClosedTime.map(minutes) ?? "",
                record.endCause?.rawValue ?? "",
                record.subject ?? "",
                record.triggerName ?? "",
                record.batteryStart.map(String.init) ?? "",
                record.batteryEnd.map(String.init) ?? "",
                record.scheduleName ?? ""
            ].map(escape).joined(separator: ",")
        }
        return ([header.joined(separator: ",")] + rows).joined(separator: "\n") + "\n"
    }

    private static func minutes(_ interval: TimeInterval) -> String {
        String(Int((interval / 60).rounded()))
    }

    private static func escape(_ field: String) -> String {
        guard field.contains(where: { $0 == "," || $0 == "\"" || $0 == "\n" }) else { return field }
        return "\"" + field.replacingOccurrences(of: "\"", with: "\"\"") + "\""
    }
}
