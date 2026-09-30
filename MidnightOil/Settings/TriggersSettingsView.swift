import MidnightOilCore
import SwiftUI

struct TriggersSettingsView: View {
    @Bindable var store: TriggerStore

    @AppStorage(Preferences.Key.triggersEnabled) private var triggersEnabled = true
    @State private var editing: Trigger?

    var body: some View {
        Form {
            Section {
                Toggle("Enable triggers", isOn: $triggersEnabled)
            } footer: {
                Text("A trigger keeps your Mac awake on its own while every one of its conditions holds.")
                    .foregroundStyle(.secondary)
            }

            Section {
                if store.triggers.isEmpty {
                    Text("No triggers yet.")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 12)
                }
                ForEach($store.triggers) { $trigger in
                    HStack(spacing: 12) {
                        Toggle("", isOn: $trigger.isEnabled)
                            .labelsHidden()
                        VStack(alignment: .leading, spacing: 2) {
                            Text(trigger.name)
                            Text(trigger.criteria.map(\.summary).joined(separator: " · "))
                                .font(.callout)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                        Spacer()
                        Button("Edit…") { editing = trigger }
                            .controlSize(.small)
                        Button("Remove", systemImage: "minus.circle") {
                            store.triggers.removeAll { $0.id == trigger.id }
                        }
                        .labelStyle(.iconOnly)
                        .buttonStyle(.borderless)
                        .foregroundStyle(.secondary)
                    }
                }
                Button("Add Trigger…") {
                    editing = Trigger(name: "New Trigger", criteria: [])
                }
            } header: {
                Text("Triggers")
            }
            .disabled(!triggersEnabled)
        }
        .formStyle(.grouped)
        .frame(height: 420)
        .sheet(item: $editing) { trigger in
            TriggerEditorView(trigger: trigger) { saved in
                if let index = store.triggers.firstIndex(where: { $0.id == saved.id }) {
                    store.triggers[index] = saved
                } else {
                    store.triggers.append(saved)
                }
            }
        }
    }
}
