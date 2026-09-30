import MidnightOilCore
import os
import ServiceManagement
import SwiftUI

struct GeneralSettingsView: View {
    private static let logger = Logger(subsystem: "app.midnightoil.MidnightOil", category: "Settings")

    let updater: Updater
    @State private var checksForUpdates: Bool

    @AppStorage(Preferences.Key.startsSessionAtLaunch) private var startsSessionAtLaunch = false
    @State private var launchesAtLogin = SMAppService.mainApp.status == .enabled

    init(updater: Updater) {
        self.updater = updater
        _checksForUpdates = State(initialValue: updater.checksAutomatically)
    }

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

            Section {
                Toggle("Check for updates automatically", isOn: $checksForUpdates)
                    .onChange(of: checksForUpdates) { _, enabled in updater.checksAutomatically = enabled }
                LabeledContent("Version \(Self.version)") {
                    Button("Check Now") { updater.checkForUpdates() }
                }
            }
        }
        .formStyle(.grouped)
    }

    private static var version: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "?"
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
