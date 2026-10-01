import MidnightOilCore
import SwiftUI

struct TriggersSettingsView: View {
    @Bindable var store: TriggerStore

    @AppStorage(Preferences.Key.triggersEnabled) private var triggersEnabled = true
    @State private var editing: Trigger?
    @State private var removing: Trigger?

    var body: some View {
        Form {
            PaneIntro(intro: Help.Pane.triggers)

            Section {
                Toggle(isOn: $triggersEnabled) { InfoLabel("Enable triggers", info: Help.enableTriggers) }
                    .help(Help.enableTriggers)
            }

            Section {
                if store.triggers.isEmpty {
                    VStack(spacing: 10) {
                        Text("No triggers yet. A common first one: stay awake whenever you're docked at your desk.")
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                        Button("Add “Docked at desk”") { store.triggers.append(Self.dockedAtDesk) }
                            .help(Help.addExampleTrigger)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
                ForEach($store.triggers) { $trigger in
                    HStack(spacing: 12) {
                        Toggle("", isOn: $trigger.isEnabled)
                            .labelsHidden()
                            .help(Help.triggerSwitch)
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
                            .help(Help.editTrigger)
                        Button("Remove", systemImage: "minus.circle") { removing = trigger }
                        .help(Help.removeTrigger)
                        .labelStyle(.iconOnly)
                        .buttonStyle(.borderless)
                        .foregroundStyle(.secondary)
                    }
                }
                Button("Add Trigger…") {
                    editing = Trigger(name: "New Trigger", criteria: [])
                }
                .help(Help.addTrigger)
            } header: {
                Text("Triggers")
            }
            .disabled(!triggersEnabled)
        }
        .formStyle(.grouped)
        .frame(height: 480)
        .confirmationDialog(
            "Remove “\(removing?.name ?? "")”?",
            isPresented: Binding(get: { removing != nil }, set: { if !$0 { removing = nil } }),
            titleVisibility: .visible
        ) {
            Button("Remove Trigger", role: .destructive) {
                store.triggers.removeAll { $0.id == removing?.id }
                removing = nil
            }
        } message: {
            Text("If it's running a session right now, that session ends.")
        }
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

    private static let dockedAtDesk = Trigger(
        name: "Docked at desk",
        criteria: [.externalDisplay(connected: true), .powerSource(.powerAdapter)]
    )
}
