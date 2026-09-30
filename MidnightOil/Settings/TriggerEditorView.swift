import AppKit
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
                    if trigger.criteria.isEmpty {
                        Text("Add at least one condition.")
                            .foregroundStyle(.secondary)
                    }
                    ForEach(trigger.criteria.indices, id: \.self) { index in
                        LabeledContent {
                            HStack {
                                CriterionEditor(criterion: $trigger.criteria[index])
                                Button("Remove", systemImage: "minus.circle") {
                                    trigger.criteria.remove(at: index)
                                }
                                .labelStyle(.iconOnly)
                                .buttonStyle(.borderless)
                                .foregroundStyle(.secondary)
                                .help(Help.removeCondition)
                            }
                        } label: {
                            InfoLabel(
                                trigger.criteria[index].kind.title,
                                info: Help.condition(trigger.criteria[index].kind)
                            )
                        }
                    }
                    Menu("Add Condition…") {
                        ForEach(CriterionKind.allCases) { kind in
                            Button(kind.title) { trigger.criteria.append(kind.defaultCriterion) }
                                .help(Help.condition(kind))
                        }
                    }
                    .fixedSize()
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

/// The value controls for one criterion.
private struct CriterionEditor: View {
    @Binding var criterion: Criterion

    var body: some View {
        switch criterion {
        case .wifiNetwork:
            listEditor(placeholder: "Network names", suggestions: WifiAccess.currentNetwork().map { [$0] } ?? [])
                .onAppear { WifiAccess.requestIfNeeded() }
        case .usbDevice:
            listEditor(placeholder: "Device names", suggestions: SystemStateReader.usbDeviceNames().sorted())
        case .bluetoothDevice:
            listEditor(placeholder: "Device names", suggestions: SystemStateReader.pairedBluetoothDeviceNames())
        case .appRunning, .appFrontmost:
            listEditor(placeholder: "Bundle identifiers", suggestions: Self.runningAppIDs())
        case .ipAddress:
            listEditor(placeholder: "Address prefixes, e.g. 192.168.1.", suggestions: SystemStateReader.ipv4Addresses())
        case .externalDisplay(let connected):
            Picker("", selection: Binding(
                get: { connected },
                set: { criterion = .externalDisplay(connected: $0) }
            )) {
                Text("Connected").tag(true)
                Text("Not connected").tag(false)
            }
            .labelsHidden()
        case .powerSource(let kind):
            Picker("", selection: Binding(get: { kind }, set: { criterion = .powerSource($0) })) {
                Text("Power adapter").tag(PowerSourceKind.powerAdapter)
                Text("Battery").tag(PowerSourceKind.battery)
            }
            .labelsHidden()
        case .batteryLevel(let comparison, let percent):
            HStack {
                Picker("", selection: Binding(
                    get: { comparison },
                    set: { criterion = .batteryLevel($0, percent: percent) }
                )) {
                    Text("At least").tag(Comparison.atLeast)
                    Text("At most").tag(Comparison.atMost)
                }
                .labelsHidden()
                Stepper(value: Binding(
                    get: { percent },
                    set: { criterion = .batteryLevel(comparison, percent: $0) }
                ), in: 5...100, step: 5) {
                    Text("\(percent)%")
                }
            }
        case .idle(let comparison, let minutes):
            HStack {
                Picker("", selection: Binding(
                    get: { comparison },
                    set: { criterion = .idle($0, minutes: minutes) }
                )) {
                    Text("Active within").tag(Comparison.atMost)
                    Text("Idle for at least").tag(Comparison.atLeast)
                }
                .labelsHidden()
                Stepper(value: Binding(
                    get: { minutes },
                    set: { criterion = .idle(comparison, minutes: $0) }
                ), in: 1...240) {
                    Text("\(minutes) min")
                }
            }
        case .schedule(let schedule):
            ScheduleEditor(schedule: Binding(get: { schedule }, set: { criterion = .schedule($0) }))
        }
    }

    private func listEditor(placeholder: String, suggestions: [String]) -> some View {
        let text = Binding(
            get: { (criterion.listValues ?? []).joined(separator: ", ") },
            set: { newValue in
                let values = newValue.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                criterion = criterion.withListValues(values.filter { !$0.isEmpty })
            }
        )
        return HStack {
            TextField(placeholder, text: text)
            Menu("Add", systemImage: "plus") {
                if suggestions.isEmpty {
                    Text("Nothing detected")
                }
                ForEach(suggestions, id: \.self) { suggestion in
                    Button(suggestion) {
                        var values = criterion.listValues ?? []
                        if !values.contains(suggestion) { values.append(suggestion) }
                        criterion = criterion.withListValues(values)
                    }
                }
            }
            .labelStyle(.iconOnly)
            .fixedSize()
        }
    }

    @MainActor
    private static func runningAppIDs() -> [String] {
        NSWorkspace.shared.runningApplications
            .filter { $0.activationPolicy == .regular }
            .compactMap(\.bundleIdentifier)
            .sorted()
    }
}

private struct ScheduleEditor: View {
    @Binding var schedule: Schedule
    private let daySymbols = Calendar.current.veryShortWeekdaySymbols

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
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
            HStack(spacing: 6) {
                Text("From")
                DatePicker("From", selection: minuteBinding(\.startMinute), displayedComponents: .hourAndMinute)
                    .labelsHidden()
                Text("to")
                DatePicker("To", selection: minuteBinding(\.endMinute), displayedComponents: .hourAndMinute)
                    .labelsHidden()
            }
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
