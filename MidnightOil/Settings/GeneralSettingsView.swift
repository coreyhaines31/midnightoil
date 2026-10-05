import MidnightOilCore
import os
import ServiceManagement
import SwiftUI

struct GeneralSettingsView: View {
    private static let logger = Logger(subsystem: "app.midnightoil.MidnightOil", category: "Settings")

    let updater: Updater
    let teams: TeamsLicense
    @State private var checksForUpdates: Bool

    @AppStorage(Preferences.Key.startsSessionAtLaunch) private var startsSessionAtLaunch = false
    @State private var launchesAtLogin = SMAppService.mainApp.status == .enabled

    init(updater: Updater, teams: TeamsLicense) {
        self.updater = updater
        self.teams = teams
        _checksForUpdates = State(initialValue: updater.checksAutomatically)
    }

    var body: some View {
        Form {
            PaneIntro(intro: Help.Pane.general)
            ManagedNotice(keys: [Preferences.Key.startsSessionAtLaunch])

            Section {
                Toggle(isOn: $launchesAtLogin) { InfoLabel("Launch at login", info: Help.launchAtLogin) }
                    .help(Help.launchAtLogin)
                    .onChange(of: launchesAtLogin) { _, enabled in
                        setLaunchAtLogin(enabled)
                    }
                Toggle(isOn: $startsSessionAtLaunch) {
                    InfoLabel("Keep the Mac awake as soon as \(Brand.name) opens", info: Help.startAtLaunch)
                }
                .help(Help.startAtLaunch)
                .managed(Preferences.Key.startsSessionAtLaunch)
            }

            Section {
                Toggle(isOn: $checksForUpdates) {
                    InfoLabel("Check for updates automatically", info: Help.automaticUpdates)
                }
                .help(Help.automaticUpdates)
                .onChange(of: checksForUpdates) { _, enabled in updater.checksAutomatically = enabled }
                LabeledContent("Version \(Self.version)") {
                    Button("Check Now") { updater.checkForUpdates() }
                        .help(Help.checkNow)
                }
            }

            TeamsSection(license: teams)
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
