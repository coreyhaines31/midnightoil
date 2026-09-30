import MidnightOilCore
import SwiftUI

struct StatisticsSettingsView: View {
    let history: SessionHistory

    private var stats: SessionStatistics { SessionStatistics.summarize(history.records) }
    private var recent: [SessionRecord] { history.records.suffix(12).reversed() }

    var body: some View {
        Form {
            Section {
                HStack(spacing: 0) {
                    tile("Sessions", "\(stats.sessionCount)")
                    Divider()
                    tile("Awake in total", Self.hours(stats.totalAwake))
                    Divider()
                    tile("This week", Self.hours(stats.awakeThisWeek))
                    Divider()
                    tile("Longest", Self.hours(stats.longest))
                    Divider()
                    tile("By triggers", "\(stats.triggeredCount)")
                }
                .padding(.vertical, 4)
            }

            Section {
                if recent.isEmpty {
                    Text("Finished sessions show up here.")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 12)
                }
                ForEach(recent) { record in
                    HStack {
                        Text(record.start.formatted(.dateTime.month(.abbreviated).day().hour().minute()))
                        Spacer()
                        Text(record.triggerName.map { "Trigger “\($0)”" } ?? "Manual")
                            .foregroundStyle(.secondary)
                        Text(RemainingTime.short(record.duration))
                            .monospacedDigit()
                            .frame(width: 70, alignment: .trailing)
                    }
                }
            } header: {
                HStack {
                    Text("Recent Sessions")
                    Spacer()
                    Button("Clear History") { history.clear() }
                        .controlSize(.small)
                        .disabled(history.records.isEmpty)
                }
            }
        }
        .formStyle(.grouped)
        .frame(height: 440)
    }

    private func tile(_ title: String, _ value: String) -> some View {
        VStack(spacing: 4) {
            Text(value).font(.title2.weight(.semibold)).monospacedDigit()
            Text(title).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private static func hours(_ interval: TimeInterval) -> String {
        interval < 60 ? "0m" : RemainingTime.short(interval)
    }
}
