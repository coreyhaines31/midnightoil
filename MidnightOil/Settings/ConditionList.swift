import AppKit
import MidnightOilCore
import SwiftUI

/// Editable conditions with an Add Condition menu, shared by triggers and schedules.
struct ConditionList: View {
    @Binding var criteria: [Criterion]
    let emptyText: String
    var kinds: [CriterionKind] = CriterionKind.allCases

    var body: some View {
        if criteria.isEmpty {
            Text(emptyText)
                .foregroundStyle(.secondary)
        }
        ForEach(criteria.indices, id: \.self) { index in
            LabeledContent {
                HStack {
                    CriterionEditor(criterion: $criteria[index])
                    Button("Remove", systemImage: "minus.circle") {
                        criteria.remove(at: index)
                    }
                    .labelStyle(.iconOnly)
                    .buttonStyle(.borderless)
                    .foregroundStyle(.secondary)
                    .help(Help.removeCondition)
                }
            } label: {
                InfoLabel(criteria[index].kind.title, info: Help.condition(criteria[index].kind))
            }
        }
        Menu("Add Condition…") {
            ForEach(kinds) { kind in
                Button(kind.title) { criteria.append(kind.defaultCriterion) }
                    .help(Help.condition(kind))
            }
        }
        .fixedSize()
    }
}

/// The value controls for one criterion.
struct CriterionEditor: View {
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
