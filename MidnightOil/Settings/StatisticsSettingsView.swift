import MidnightOilCore
import SwiftUI

struct StatisticsSettingsView: View {
    let history: SessionHistory

    private var stats: SessionStatistics { SessionStatistics.summarize(history.records) }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                tile("Sessions", "\(stats.sessionCount)")
                tile("Awake in total", Self.hours(stats.totalAwake))
                tile("This week", Self.hours(stats.awakeThisWeek))
                tile("Longest", Self.hours(stats.longest))
                tile("By triggers", "\(stats.triggeredCount)")
            }

            Table(history.records.reversed()) {
                TableColumn("Started") { record in
                    Text(record.start.formatted(.dateTime.month(.abbreviated).day().hour().minute()))
                }
                TableColumn("Length") { record in
                    Text(RemainingTime.short(record.duration))
                }
                .width(90)
                TableColumn("Started by") { record in
                    Text(record.triggerName.map { "Trigger “\($0)”" } ?? "You")
                }
            }
            .overlay {
                if history.records.isEmpty {
                    Text("Finished sessions show up here.").foregroundStyle(.secondary)
                }
            }

            HStack {
                Spacer()
                Button("Clear History") { history.clear() }
                    .disabled(history.records.isEmpty)
            }
        }
        .padding()
    }

    private func tile(_ title: String, _ value: String) -> some View {
        VStack(spacing: 4) {
            Text(value).font(.title2.weight(.semibold)).monospacedDigit()
            Text(title).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 8))
    }

    private static func hours(_ interval: TimeInterval) -> String {
        interval < 60 ? "0m" : RemainingTime.short(interval)
    }
}
