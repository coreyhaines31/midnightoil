import PanelKit
import SwiftUI

/// The 24-hour meter: 0 to 24 across the scale, the night hours (before 6 and after 18) shaded,
/// the session's span printed as a band, and the needle on the current time.
struct DayMeter: View {
    var span: ClosedRange<Date>
    var now: Date
    var accessibilityValue: String

    var body: some View {
        Meter(
            MeterConfig(
                majorTicks: 4,
                minorTicks: 6,
                bands: [
                    MeterBand(0...0.25, width: 9, opacity: 0.14),
                    MeterBand(0.75...1, width: 9, opacity: 0.14)
                ] + Self.spanBands(span).map { MeterBand($0, width: 3, opacity: 0.9) },
                labels: [.init(0, "0"), .init(0.25, "6"), .init(0.5, "12"), .init(0.75, "18"), .init(1, "24")],
                word: "HOURS",
                face: .lit,
                accessibilityLabel: "24-hour meter"
            ),
            value: Self.fraction(of: now),
            accessibilityValue: accessibilityValue
        )
    }

    /// Where a time falls on the 24-hour scale (0...1).
    static func fraction(of date: Date, calendar: Calendar = .current) -> Double {
        let seconds = date.timeIntervalSince(calendar.startOfDay(for: date))
        return min(max(seconds / 86_400, 0), 1)
    }

    /// The span as one or two ranges on the scale, split at midnight; a full day or more fills the scale.
    static func spanBands(_ span: ClosedRange<Date>, calendar: Calendar = .current) -> [ClosedRange<Double>] {
        let length = span.upperBound.timeIntervalSince(span.lowerBound)
        guard length > 0 else { return [] }
        if length >= 86_400 { return [0...1] }
        let start = fraction(of: span.lowerBound, calendar: calendar)
        let end = fraction(of: span.upperBound, calendar: calendar)
        return end >= start ? [start...end] : [start...1, 0...end]
    }
}
