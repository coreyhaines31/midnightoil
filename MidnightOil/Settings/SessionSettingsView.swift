import SwiftUI

struct SessionSettingsView: View {
    @AppStorage(Preferences.Key.allowsDisplaySleep) private var allowsDisplaySleep = false
    @AppStorage(Preferences.Key.batteryFloorEnabled) private var batteryFloorEnabled = false
    @AppStorage(Preferences.Key.batteryFloorPercent)
    private var batteryFloorPercent = Preferences.defaultBatteryFloorPercent
    @AppStorage(Preferences.Key.notifiesOnSessionEnd) private var notifiesOnSessionEnd = true

    var body: some View {
        Form {
            Section {
                Toggle("Allow display sleep", isOn: $allowsDisplaySleep)
            } footer: {
                Text("New sessions keep your Mac awake but let the screen turn off on its normal schedule.")
                    .foregroundStyle(.secondary)
            }

            Section {
                Toggle("End sessions when the battery is low", isOn: $batteryFloorEnabled)
                Stepper(value: $batteryFloorPercent, in: 5...50, step: 5) {
                    Text("Below \(batteryFloorPercent)%")
                }
                .disabled(!batteryFloorEnabled)
            } footer: {
                Text("Only applies while running on battery.")
                    .foregroundStyle(.secondary)
            }

            Section {
                Toggle("Notify me when a session ends on its own", isOn: $notifiesOnSessionEnd)
            }
        }
        .formStyle(.grouped)
    }
}
