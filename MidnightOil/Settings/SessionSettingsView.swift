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

            Section {
                Toggle(isOn: $allowsDisplaySleep) { InfoLabel("Allow display sleep", info: Help.allowDisplaySleep) }
                    .help(Help.allowDisplaySleep)
            }

            Section {
                Toggle(isOn: $endsWhenUnplugged) {
                    InfoLabel("End sessions when unplugged from power", info: Help.endWhenUnplugged)
                }
                .help(Help.endWhenUnplugged)
                Toggle(isOn: $batteryFloorEnabled) {
                    InfoLabel("End sessions when the battery is low", info: Help.endOnLowBattery)
                }
                .help(Help.endOnLowBattery)
                Stepper(value: $batteryFloorPercent, in: 5...50, step: 5) {
                    Text("Below \(batteryFloorPercent)%")
                }
                .help(Help.batteryLevel)
                .disabled(!batteryFloorEnabled)
            } header: {
                Text("Safety")
            }
        }
        .formStyle(.grouped)
    }
}
