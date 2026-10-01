import MidnightOilCore
import SwiftUI

struct ScheduleEditorView: View {
    @State private var schedule: AwakeSchedule
    private let onSave: (AwakeSchedule) -> Void
    @Environment(\.dismiss) private var dismiss

    init(schedule: AwakeSchedule, onSave: @escaping (AwakeSchedule) -> Void) {
        _schedule = State(initialValue: schedule)
        self.onSave = onSave
    }

    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section {
                    TextField("Name", text: $schedule.name, prompt: Text("Name"))
                        .multilineTextAlignment(.leading)
                }

                Section {
                    ScheduleEditor(schedule: $schedule.schedule)
                } header: {
                    InfoLabel("When", info: Help.scheduleWhen)
                } footer: {
                    if let problem {
                        Text(problem).foregroundStyle(.secondary)
                    } else if schedule.schedule.endMinute < schedule.schedule.startMinute {
                        Text("Runs past midnight and ends the next morning.").foregroundStyle(.secondary)
                    }
                }

                Section {
                    ConditionList(
                        criteria: $schedule.conditions,
                        emptyText: "None. The schedule runs for its whole window.",
                        kinds: CriterionKind.allCases.filter { $0 != .schedule }
                    )
                } header: {
                    InfoLabel("Only While", info: Help.scheduleConditions)
                }

                Section {
                    Toggle(isOn: $schedule.allowsDisplaySleep) {
                        InfoLabel("Allow display sleep", info: Help.allowDisplaySleep)
                    }
                    .help(Help.allowDisplaySleep)
                    if LidState.hasLid {
                        Toggle(isOn: $schedule.staysAwakeWithLidClosed) {
                            InfoLabel("Stay awake with the lid closed", info: Help.Menu.staysAwakeWithLidClosed)
                        }
                        .help(Help.Menu.staysAwakeWithLidClosed)
                    }
                } header: {
                    InfoLabel("Session", info: Help.scheduleSessionOptions)
                }
            }
            .formStyle(.grouped)

            Divider()
            HStack {
                Spacer()
                Button("Cancel") { dismiss() }
                    .keyboardShortcut(.cancelAction)
                Button("Save") {
                    onSave(schedule)
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(schedule.name.isEmpty || problem != nil)
            }
            .padding(16)
        }
        .frame(width: 640, height: 496)
    }

    /// Why the schedule can't be saved yet, if anything.
    private var problem: String? {
        let times = schedule.schedule
        if times.days.isEmpty { return "Pick at least one day." }
        if times.startMinute == times.endMinute { return "Pick an end time different from the start." }
        return nil
    }
}
