import MidnightOilCore
import SwiftUI

/// Day buttons and a from–to time range, shared by schedules and the trigger editor.
struct ScheduleEditor: View {
    @Binding var schedule: Schedule
    private let daySymbols = Calendar.current.veryShortWeekdaySymbols

    var body: some View {
        // One row when there's room, as in the schedule editor; stacked inside a trigger's condition row.
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 16) { dayButtons; timeRange }
            VStack(alignment: .leading, spacing: 8) { dayButtons; timeRange }
        }
    }

    private var dayButtons: some View {
        HStack(spacing: 4) {
            ForEach(1...7, id: \.self) { day in
                Toggle(daySymbols[day - 1], isOn: Binding(
                    get: { schedule.days.contains(day) },
                    set: { included in
                        if included { schedule.days.insert(day) } else { schedule.days.remove(day) }
                    }
                ))
                .toggleStyle(.button)
            }
        }
    }

    private var timeRange: some View {
        HStack(spacing: 6) {
            Text("From")
            DatePicker("From", selection: minuteBinding(\.startMinute), displayedComponents: .hourAndMinute)
                .labelsHidden()
            Text("to")
            DatePicker("To", selection: minuteBinding(\.endMinute), displayedComponents: .hourAndMinute)
                .labelsHidden()
        }
    }

    private func minuteBinding(_ keyPath: WritableKeyPath<Schedule, Int>) -> Binding<Date> {
        Binding(
            get: {
                let minutes = schedule[keyPath: keyPath]
                return Calendar.current.date(from: DateComponents(hour: minutes / 60, minute: minutes % 60)) ?? .now
            },
            set: { date in
                let parts = Calendar.current.dateComponents([.hour, .minute], from: date)
                schedule[keyPath: keyPath] = (parts.hour ?? 0) * 60 + (parts.minute ?? 0)
            }
        )
    }
}

extension Schedule {
    /// "Weekdays · 9:00 AM – 5:00 PM"
    var summary: String {
        "\(daysSummary(calendar: .current)) · \(Self.clock(startMinute)) – \(Self.clock(endMinute))"
    }

    static func clock(_ minutes: Int) -> String {
        let date = Calendar.current.date(from: DateComponents(hour: minutes / 60, minute: minutes % 60)) ?? .now
        return date.formatted(.dateTime.hour().minute())
    }
}

extension AwakeSchedule {
    /// "Weekdays · 9:00 AM – 5:00 PM · On power adapter"
    var summary: String {
        ([schedule.summary] + conditions.map(\.summary)).joined(separator: " · ")
    }
}
