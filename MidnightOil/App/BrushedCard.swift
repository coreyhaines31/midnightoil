import PanelKit
import SwiftUI

/// The Brushed card at the top of the menu: always black anodised with a lit meter, Midnight Oil's
/// night instrument, inset in the native menu like the family mockup.
struct BrushedMenuCard<Content: View>: View {
    static var menuWidth: CGFloat { 340 }

    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content
        }
        .foregroundStyle(PanelTheme.dark.ink)
        .font(PanelFont.body(13))
        .background(PanelTheme.dark.background)
        .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .strokeBorder(.black.opacity(0.12), lineWidth: 1)
        )
        .padding(.horizontal, 5)
        .padding(.top, 1)
        .padding(.bottom, 5)
        .frame(width: Self.menuWidth)
        .environment(\.colorScheme, .dark)
        .environment(\.panelThemeOverride, .dark)
        .panelAccent(PanelAccent.midnightOil)
    }
}

/// PanelKit's `Fascia` with a pilot light that can be off (idle), so the nameplate says whether
/// the Mac is being kept awake right now.
struct OilFascia<Instrument: View>: View {
    var timestamp: String
    var detail: String
    var label: String
    var isLit = true
    @ViewBuilder let instrument: Instrument

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center, spacing: 10) {
                Nameplate("Awake", isLit: isLit)
                Spacer(minLength: 0)
                Text(timestamp)
                    .font(PanelFont.body(11.5))
                    .monospacedDigit()
                    .foregroundStyle(PanelTheme.dark.ink2)
                    .lineLimit(1)
            }
            instrument
            LabelStrips(label, detail: detail)
        }
        .padding(.top, 11)
        .padding(.horizontal, 14)
        .padding(.bottom, 13)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(BrushedMetal(anodised: true))
        .overlay(alignment: .top) {
            Rectangle().fill(PanelTheme.dark.fasciaHighlight).frame(height: 1)
        }
        .overlay(alignment: .bottom) {
            Rectangle().fill(PanelTheme.dark.fasciaEdge).frame(height: 1)
        }
    }
}

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
