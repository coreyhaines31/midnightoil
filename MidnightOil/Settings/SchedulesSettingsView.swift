import MidnightOilCore
import SwiftUI

struct SchedulesSettingsView: View {
    @Bindable var store: ScheduleStore

    @State private var editing: AwakeSchedule?
    @State private var removing: AwakeSchedule?

    var body: some View {
        Form {
            PaneIntro(intro: Help.Pane.schedules)

            Section {
                if store.schedules.isEmpty {
                    VStack(spacing: 10) {
                        Text("No schedules yet. Start with one of these, then change the days and hours to fit.")
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                        HStack {
                            Button("Add “Work hours”") { store.schedules.append(Self.fresh(.workHours)) }
                                .help(Help.addWorkHours)
                            Button("Add “Overnight”") { store.schedules.append(Self.fresh(.overnight)) }
                                .help(Help.addOvernight)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
                ForEach($store.schedules) { $schedule in
                    HStack(spacing: 12) {
                        Toggle("", isOn: $schedule.isEnabled)
                            .labelsHidden()
                            .help(Help.scheduleSwitch)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(schedule.name)
                            Text(schedule.summary)
                                .font(.callout)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                        Spacer()
                        Button("Edit…") { editing = schedule }
                            .controlSize(.small)
                            .help(Help.editSchedule)
                        Button("Remove", systemImage: "minus.circle") { removing = schedule }
                            .help(Help.removeSchedule)
                            .labelStyle(.iconOnly)
                            .buttonStyle(.borderless)
                            .foregroundStyle(.secondary)
                    }
                }
                Button("Add Schedule…") { editing = Self.fresh(.workHours, name: "New Schedule") }
                    .help(Help.addSchedule)
            } header: {
                Text("Schedules")
            } footer: {
                Text(Help.scheduleSkip)
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .frame(height: 440)
        .confirmationDialog(
            "Remove “\(removing?.name ?? "")”?",
            isPresented: Binding(get: { removing != nil }, set: { if !$0 { removing = nil } }),
            titleVisibility: .visible
        ) {
            Button("Remove Schedule", role: .destructive) {
                store.schedules.removeAll { $0.id == removing?.id }
                removing = nil
            }
        } message: {
            Text("If it's running a session right now, that session ends.")
        }
        .sheet(item: $editing) { schedule in
            ScheduleEditorView(schedule: schedule) { saved in
                if let index = store.schedules.firstIndex(where: { $0.id == saved.id }) {
                    store.schedules[index] = saved
                } else {
                    store.schedules.append(saved)
                }
            }
        }
    }

    /// A copy of a preset with its own id, so adding it twice gives two schedules.
    private static func fresh(_ preset: AwakeSchedule, name: String? = nil) -> AwakeSchedule {
        var schedule = preset
        schedule.id = UUID()
        if let name { schedule.name = name }
        return schedule
    }
}
