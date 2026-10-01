import ServiceManagement
import SwiftUI

struct ClosedLidSettingsView: View {
    let helper: HelperClient

    @State private var status: HelperClient.Status = .notInstalled
    @AppStorage(Preferences.Key.staysAwakeWithLidClosed) private var staysAwakeWithLidClosed = false
    @AppStorage(Preferences.Key.soundsLidAlarm) private var soundsLidAlarm = true

    var body: some View {
        Form {
            PaneIntro(intro: Help.Pane.closedLid)
            ManagedNotice(keys: [Preferences.Key.staysAwakeWithLidClosed, Preferences.Key.soundsLidAlarm])

            Section {
                LabeledContent {
                    helperControls
                } label: {
                    InfoLabel("Closed-lid helper", info: Help.helper)
                }
            } footer: {
                Text(Help.lidDisplayNote)
                    .foregroundStyle(.secondary)
            }

            Section {
                InfoRow(
                    title: "Stay awake with the lid closed by default",
                    info: Help.lidDefault,
                    isDisabled: status != .installed
                ) {
                    Toggle("Stay awake with the lid closed by default", isOn: $staysAwakeWithLidClosed)
                        .toggleStyle(.switch)
                        .managed(Preferences.Key.staysAwakeWithLidClosed)
                }
                Toggle(isOn: $soundsLidAlarm) {
                    InfoLabel("Sound an alarm if the lid closes on battery", info: Help.lidAlarm)
                }
                .help(Help.lidAlarm)
                .managed(Preferences.Key.soundsLidAlarm)
            }
        }
        .formStyle(.grouped)
        .task {
            // Approval happens in System Settings, so keep the status fresh while visible.
            while !Task.isCancelled {
                status = helper.status
                try? await Task.sleep(for: .seconds(2))
            }
        }
    }

    @ViewBuilder private var helperControls: some View {
        switch status {
        case .installed:
            HStack {
                Label("Installed", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                Button("Remove") {
                    Task {
                        await helper.uninstall()
                        status = helper.status
                    }
                }
                .help(Help.removeHelper)
            }
        case .needsApproval:
            Button("Approve in System Settings…") {
                SMAppService.openSystemSettingsLoginItems()
            }
            .help(Help.approveHelper)
        case .notInstalled:
            Button("Install…") {
                helper.install()
                status = helper.status
            }
            .help(Help.installHelper)
        }
    }
}
