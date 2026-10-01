import AppKit
import Charts
import MidnightOilCore
import SwiftUI

struct StatisticsSettingsView: View {
    let history: SessionHistory
    @State private var confirmingClear = false

    private var stats: SessionStatistics { SessionStatistics.summarize(history.records) }
    private var week: [DayTotal] { DailyTotals.make(history.records, days: 7) }

    var body: some View {
        Form {
            PaneIntro(intro: Help.Pane.statistics)

            Section {
                VStack(alignment: .leading, spacing: 4) {
                    Text(Self.hours(week.reduce(0) { $0 + $1.away }))
                        .font(.system(size: 34, weight: .bold))
                        .monospacedDigit()
                    HStack(spacing: 6) {
                        Text("worked while you were away in the last 7 days")
                            .foregroundStyle(.secondary)
                        InfoButton(text: Help.away)
                    }
                    Text("\(Self.hours(week.reduce(0) { $0 + $1.awake })) awake in total")
                        .font(.callout)
                        .foregroundStyle(.tertiary)
                }
                .padding(.vertical, 4)

                WeekChart(days: week)
                    .frame(height: 150)
                    .help(Help.chart)
                    .padding(.vertical, 6)
            }

            Section {
                HStack(spacing: 0) {
                    tile("Sessions", "\(stats.sessionCount)", help: Help.tileSessions)
                    Divider()
                    tile("Away, all time", Self.hours(stats.totalAway), help: Help.tileAwayAllTime)
                    Divider()
                    tile("Longest", Self.hours(stats.longest), help: Help.tileLongest)
                    Divider()
                    tile("Lid closed", Self.hours(stats.lidClosedTotal), help: Help.tileLidClosed)
                }
                .padding(.vertical, 4)
            }

            SessionList(records: history.records)

            Section {
                HStack {
                    Button("Export CSV…") { export() }
                        .help(Help.exportCSV)
                    Spacer()
                    Button("Clear History…", role: .destructive) { confirmingClear = true }
                        .help(Help.clearHistory)
                }
                .disabled(history.records.isEmpty)
            }
        }
        .formStyle(.grouped)
        .frame(height: 660)
        .confirmationDialog(
            "Clear all session history?",
            isPresented: $confirmingClear,
            titleVisibility: .visible
        ) {
            Button("Clear History", role: .destructive) { history.clear() }
        } message: {
            Text(Help.clearHistoryConfirm)
        }
    }

    private func tile(_ title: String, _ value: String, help: String) -> some View {
        VStack(spacing: 4) {
            Text(value).font(.title2.weight(.semibold)).monospacedDigit()
            Text(title).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .help(help)
    }

    static func hours(_ interval: TimeInterval) -> String {
        interval < 60 ? "0m" : RemainingTime.short(interval)
    }

    private func export() {
        let panel = NSSavePanel()
        panel.nameFieldStringValue = "Midnight Oil sessions.csv"
        panel.allowedContentTypes = [.commaSeparatedText]
        NSApp.activate()
        guard panel.runModal() == .OK, let url = panel.url else { return }
        do {
            try SessionCSV.make(history.records).write(to: url, atomically: true, encoding: .utf8)
        } catch {
            NSAlert(error: error).runModal()
        }
    }
}

/// Last 7 days: time the Mac worked while you were away, stacked on time you were there.
private struct WeekChart: View {
    let days: [DayTotal]

    var body: some View {
        Chart {
            ForEach(days) { day in
                BarMark(x: .value("Day", day.day, unit: .day), y: .value("Hours", day.away / 3_600))
                    .foregroundStyle(by: .value("Kind", "While you were away"))
                BarMark(x: .value("Day", day.day, unit: .day), y: .value("Hours", day.withYou / 3_600))
                    .foregroundStyle(by: .value("Kind", "With you"))
            }
        }
        // Keep at least an hour of scale so short weeks get sensible ticks (0, 15m, 30m…).
        .chartYScale(domain: 0...max(1, days.map { $0.awake / 3_600 }.max() ?? 0))
        .chartForegroundStyleScale([
            "While you were away": Color.orange,
            "With you": Color.secondary.opacity(0.35)
        ])
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) { _ in
                AxisValueLabel(format: .dateTime.weekday(.abbreviated), centered: true)
            }
        }
        .chartYAxis {
            AxisMarks { value in
                AxisGridLine()
                AxisValueLabel { if let hours = value.as(Double.self) { Text(Self.axisLabel(hours)) } }
            }
        }
        .chartLegend(position: .bottom, alignment: .leading)
    }

    /// "0", "15m", "1h", "1.5h": whole hours when they are, minutes under an hour.
    static func axisLabel(_ hours: Double) -> String {
        if hours == 0 { return "0" }
        if hours < 1 { return "\(Int((hours * 60).rounded()))m" }
        if hours == hours.rounded() { return "\(Int(hours))h" }
        return String(format: "%.1fh", hours)
    }
}

/// Recent sessions grouped by the day they ended.
private struct SessionList: View {
    let records: [SessionRecord]

    private var groups: [(day: Date, records: [SessionRecord])] {
        let recent = records.suffix(30).reversed()
        let grouped = Dictionary(grouping: recent) { Calendar.current.startOfDay(for: $0.end) }
        return grouped.keys.sorted(by: >).map { ($0, grouped[$0] ?? []) }
    }

    var body: some View {
        if records.isEmpty {
            Section("Recent Sessions") {
                Text("Finished sessions show up here.")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 12)
            }
        }
        ForEach(groups, id: \.day) { group in
            Section(Self.dayTitle(group.day)) {
                ForEach(group.records) { SessionRow(record: $0) }
            }
        }
    }

    private static func dayTitle(_ day: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(day) { return "Today" }
        if calendar.isDateInYesterday(day) { return "Yesterday" }
        return day.formatted(.dateTime.weekday(.wide).month(.abbreviated).day())
    }
}

private struct SessionRow: View {
    let record: SessionRecord

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: Self.symbol(for: record.endCause))
                .foregroundStyle(record.away >= 60 ? Color.orange : Color.secondary)
                .frame(width: 18)
                .padding(.top, 2)
                .help(record.endCause?.label ?? "Ended")
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                Text(details)
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(RemainingTime.short(record.awake))
                .monospacedDigit()
        }
    }

    private var title: String {
        let range = "\(record.start.formatted(date: .omitted, time: .shortened)) – "
            + record.end.formatted(date: .omitted, time: .shortened)
        let what = record.subject
            ?? record.scheduleName.map { "Schedule “\($0)”" }
            ?? record.triggerName.map { "Trigger “\($0)”" }
        return [range, what].compactMap(\.self).joined(separator: " · ")
    }

    private var details: String {
        var parts: [String] = []
        if record.away >= 60 { parts.append("\(RemainingTime.short(record.away)) away") }
        if let lid = record.lidClosedTime, lid >= 60 { parts.append("lid closed \(RemainingTime.short(lid))") }
        if let start = record.batteryStart, let end = record.batteryEnd, start != end {
            parts.append("battery \(start)% → \(end)%")
        }
        parts.append(record.endCause?.label ?? "Ended")
        return parts.joined(separator: " · ")
    }

    // One symbol per cause; a lookup table would only hide the mapping.
    // swiftlint:disable:next cyclomatic_complexity
    static func symbol(for cause: SessionEndCause?) -> String {
        switch cause {
        case .you: "hand.tap"
        case .timeUp: "clock"
        case .appQuit: "xmark.app"
        case .downloadFinished: "arrow.down.circle"
        case .lowBattery: "battery.25percent"
        case .unplugged: "powerplug"
        case .triggerEnded: "bolt.slash"
        case .scheduleEnded: "calendar"
        case .schedulePaused: "pause.circle"
        case .policyLimit: "building.2"
        case .replaced: "arrow.triangle.2.circlepath"
        case .midnightOilQuit: "power"
        case .unknown, nil: "circle"
        }
    }
}
