import Foundation

/// The instrument the menu's fascia shows for a session.
public enum SessionGauge: Equatable, Sendable {
    /// Tape reels turning with an elapsed counter: the session runs until something else ends it.
    case reels
    /// A needle sweeping down to zero: the session has a length.
    case countdown
    /// The 24-hour dial with the end time marked: the session ends at a clock time.
    case clock

    /// Picks the instrument for a session. A schedule's window closes at a clock time, so it reads
    /// on the dial; an organization's time limit is a length, so it counts down.
    public static func pick(for session: Session, endsWithScheduleWindow: Bool, hasPolicyCutoff: Bool) -> SessionGauge {
        if endsWithScheduleWindow { return .clock }
        switch session.end {
        case .until: return .clock
        case .after: return .countdown
        case .indefinite, .whileAppRunning, .whileDownloading, .whileProcessesRunning:
            return hasPolicyCutoff ? .countdown : .reels
        }
    }
}

/// The printed scale of the countdown meter: zero at the left stop, the session's length at the right.
public struct CountdownScale: Equatable, Sendable {
    /// The word printed on the face, e.g. "MIN LEFT".
    public let word: String
    /// Major divisions on the scale.
    public let divisions: Int
    /// Scale labels as (position 0...1, text).
    public let labels: [Label]

    public struct Label: Equatable, Sendable {
        public let position: Double
        public let text: String
    }

    /// Steps the scale can count in, shortest first.
    private static let steps: [TimeInterval] = [
        60, 120, 300, 600, 900, 1_200, 1_800, 3_600, 7_200, 10_800, 14_400, 21_600
    ]

    public init(total: TimeInterval) {
        let total = max(total, 60)
        let inMinutes = total <= 90 * 60
        let unit: TimeInterval = inMinutes ? 60 : 3_600
        word = inMinutes ? "MIN LEFT" : "HRS LEFT"

        func text(_ seconds: TimeInterval) -> String {
            let value = seconds / unit
            let whole = value.rounded()
            if abs(value - whole) < 0.01 { return String(Int(whole)) }
            return String(format: "%.1f", value)
        }

        // Prefer a step that splits the length into 3 to 5 equal parts, then 2 or 6.
        let fits: (ClosedRange<Int>) -> (TimeInterval, Int)? = { range in
            for step in Self.steps {
                let count = total / step
                let whole = count.rounded()
                if abs(count - whole) < 1e-6, range.contains(Int(whole)) { return (step, Int(whole)) }
            }
            return nil
        }
        if let (step, count) = fits(3...5) ?? fits(2...6) {
            divisions = count
            labels = (0...count).map { Label(position: Double($0) / Double(count), text: text(Double($0) * step)) }
        } else {
            // An odd length, e.g. after Extend Session: mark only the ends.
            divisions = 4
            labels = [Label(position: 0, text: "0"), Label(position: 1, text: text(total))]
        }
    }

    /// Where the needle sits: the share of the session still to run (1 at the start, 0 at the end).
    public static func needle(remaining: TimeInterval, total: TimeInterval) -> Double {
        guard total > 0 else { return 0 }
        return min(max(remaining / total, 0), 1)
    }
}

/// The tape counter's digits for an elapsed time, as hours and minutes ("01", "23").
/// Stops at 99:59 because the counter has two drums for hours.
public enum ElapsedCounter {
    public static func digits(_ interval: TimeInterval) -> (hours: String, minutes: String) {
        let minutes = min(max(0, Int(interval / 60)), 99 * 60 + 59)
        return (String(format: "%02d", minutes / 60), String(format: "%02d", minutes % 60))
    }
}
