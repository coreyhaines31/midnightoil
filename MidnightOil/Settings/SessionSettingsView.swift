import SwiftUI

struct SessionSettingsView: View {
    @AppStorage(Preferences.Key.allowsDisplaySleep) private var allowsDisplaySleep = false
    @AppStorage(Preferences.Key.batteryFloorEnabled) private var batteryFloorEnabled = false
    @AppStorage(Preferences.Key.batteryFloorPercent)
    private var batteryFloorPercent = Preferences.defaultBatteryFloorPercent
    @AppStorage(Preferences.Key.endsWhenUnplugged) private var endsWhenUnplugged = false

    var body: some View {
        Form {
            PaneIntro(intro: Help.Pane.sessions)
            ManagedNotice(keys: [
                Preferences.Key.allowsDisplaySleep,
                Preferences.Key.endsWhenUnplugged,
                Preferences.Key.batteryFloorEnabled,
                Preferences.Key.batteryFloorPercent
            ])

            Section {
                Toggle(isOn: $allowsDisplaySleep) { InfoLabel("Allow display sleep", info: Help.allowDisplaySleep) }
                    .help(Help.allowDisplaySleep)
                    .managed(Preferences.Key.allowsDisplaySleep)
            }

            Section {
                Toggle(isOn: $endsWhenUnplugged) {
                    InfoLabel("End sessions when unplugged from power", info: Help.endWhenUnplugged)
                }
                .help(Help.endWhenUnplugged)
                .managed(Preferences.Key.endsWhenUnplugged)
                Toggle(isOn: $batteryFloorEnabled) {
                    InfoLabel("End sessions when the battery is low", info: Help.endOnLowBattery)
                }
                .help(Help.endOnLowBattery)
                .managed(Preferences.Key.batteryFloorEnabled)
                Stepper(value: $batteryFloorPercent, in: 5...50, step: 5) {
                    Text("Below \(batteryFloorPercent)%")
                }
                .help(Help.batteryLevel)
                .disabled(!batteryFloorEnabled)
                .managed(Preferences.Key.batteryFloorPercent)
            } header: {
                Text("Safety")
            }
        }
        .formStyle(.grouped)
    }
}
