import MidnightOilCore
import os
import ServiceManagement
import SwiftUI

struct GeneralSettingsView: View {
    private static let logger = Logger(subsystem: "app.midnightoil.MidnightOil", category: "Settings")

    @AppStorage(Preferences.Key.startsSessionAtLaunch) private var startsSessionAtLaunch = false
    @State private var launchesAtLogin = SMAppService.mainApp.status == .enabled

    var body: some View {
        Form {
            Section {
                Toggle("Launch at login", isOn: $launchesAtLogin)
                    .onChange(of: launchesAtLogin) { _, enabled in
                        setLaunchAtLogin(enabled)
                    }
                Toggle("Keep the Mac awake as soon as \(Brand.name) opens", isOn: $startsSessionAtLaunch)
            } footer: {
                Text("Together, these keep your Mac awake from the moment you log in.")
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
    }

    private func setLaunchAtLogin(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            Self.logger.error("Couldn't change launch at login: \(error.localizedDescription)")
            launchesAtLogin = SMAppService.mainApp.status == .enabled
        }
    }
}
