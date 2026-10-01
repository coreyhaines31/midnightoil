import MidnightOilCore
import SwiftUI

struct TriggerEditorView: View {
    @State private var trigger: Trigger
    private let onSave: (Trigger) -> Void
    @Environment(\.dismiss) private var dismiss

    init(trigger: Trigger, onSave: @escaping (Trigger) -> Void) {
        _trigger = State(initialValue: trigger)
        self.onSave = onSave
    }

    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section {
                    TextField("Name", text: $trigger.name, prompt: Text("Name"))
                        .multilineTextAlignment(.leading)
                }

                Section {
                    ConditionList(criteria: $trigger.criteria, emptyText: "Add at least one condition.")
                } header: {
                    InfoLabel("Conditions", info: Help.triggerConditions)
                }

                Section {
                    Toggle(isOn: $trigger.allowsDisplaySleep) {
                        InfoLabel("Allow display sleep", info: Help.allowDisplaySleep)
                    }
                    .help(Help.allowDisplaySleep)
                    if LidState.hasLid {
                        Toggle(isOn: $trigger.staysAwakeWithLidClosed) {
                            InfoLabel("Stay awake with the lid closed", info: Help.Menu.staysAwakeWithLidClosed)
                        }
                        .help(Help.Menu.staysAwakeWithLidClosed)
                    }
                } header: {
                    InfoLabel("Session", info: Help.triggerSessionOptions)
                }
            }
            .formStyle(.grouped)

            Divider()
            HStack {
                Spacer()
                Button("Cancel") { dismiss() }
                    .keyboardShortcut(.cancelAction)
                Button("Save") {
                    onSave(trigger)
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(trigger.name.isEmpty || trigger.criteria.isEmpty)
            }
            .padding(16)
        }
        .frame(width: 600, height: 470)
    }
}
