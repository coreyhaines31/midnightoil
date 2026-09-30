import MidnightOilCore
import SwiftUI

struct TriggersSettingsView: View {
    @Bindable var store: TriggerStore

    @AppStorage(Preferences.Key.triggersEnabled) private var triggersEnabled = true
    @State private var selection: Trigger.ID?
    @State private var editing: Trigger?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle("Enable triggers", isOn: $triggersEnabled)
            Text("A trigger keeps your Mac awake while every one of its conditions holds.")
                .font(.callout)
                .foregroundStyle(.secondary)

            List(selection: $selection) {
                ForEach($store.triggers) { $trigger in
                    HStack {
                        Toggle("", isOn: $trigger.isEnabled)
                            .labelsHidden()
                        VStack(alignment: .leading) {
                            Text(trigger.name)
                            Text(trigger.criteria.map(\.summary).joined(separator: " · "))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    }
                    .tag(trigger.id)
                }
            }
            .overlay {
                if store.triggers.isEmpty {
                    Text("No triggers yet. Click + to add one.")
                        .foregroundStyle(.secondary)
                }
            }

            HStack {
                Button("Add", systemImage: "plus") {
                    editing = Trigger(name: "New Trigger", criteria: [])
                }
                Button("Remove", systemImage: "minus") {
                    store.triggers.removeAll { $0.id == selection }
                    selection = nil
                }
                .disabled(selection == nil)
                Spacer()
                Button("Edit…") {
                    editing = store.triggers.first { $0.id == selection }
                }
                .disabled(selection == nil)
            }
            .labelStyle(.iconOnly)
        }
        .padding()
        .disabled(!triggersEnabled)
        .sheet(item: $editing) { trigger in
            TriggerEditorView(trigger: trigger) { saved in
                if let index = store.triggers.firstIndex(where: { $0.id == saved.id }) {
                    store.triggers[index] = saved
                } else {
                    store.triggers.append(saved)
                }
                selection = saved.id
            }
        }
    }
}
