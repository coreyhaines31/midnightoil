import ServiceManagement
import SwiftUI

struct ClosedLidSettingsView: View {
    let helper: HelperClient

    @State private var status: HelperClient.Status = .notInstalled
    @AppStorage(Preferences.Key.staysAwakeWithLidClosed) private var staysAwakeWithLidClosed = false
    @AppStorage(Preferences.Key.soundsLidAlarm) private var soundsLidAlarm = true

    var body: some View {
        Form {
            Section {
                LabeledContent("Closed-lid helper") {
                    helperControls
                }
            } footer: {
                Text("""
                    macOS sleeps a laptop when its lid closes. The helper turns that off only while a \
                    session asks for it, and restores sleep when the session ends or the app quits. \
                    With an external display and power connected, no helper is needed.
                    """)
                .foregroundStyle(.secondary)
            }

            Section {
                Toggle("Stay awake with the lid closed by default", isOn: $staysAwakeWithLidClosed)
                    .disabled(status != .installed)
                Toggle("Sound an alarm if the lid closes on battery", isOn: $soundsLidAlarm)
            } footer: {
                Text("A reminder that your Mac is still running, so it doesn't overheat in a bag.")
                    .foregroundStyle(.secondary)
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
            }
        case .needsApproval:
            Button("Approve in System Settings…") {
                SMAppService.openSystemSettingsLoginItems()
            }
        case .notInstalled:
            Button("Install…") {
                helper.install()
                status = helper.status
            }
        }
    }
}
