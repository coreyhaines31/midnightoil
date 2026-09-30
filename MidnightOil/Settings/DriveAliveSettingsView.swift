import SwiftUI

struct DriveAliveSettingsView: View {
    @AppStorage(Preferences.Key.driveAliveEnabled) private var enabled = false
    @AppStorage(Preferences.Key.driveAliveInterval) private var interval = 10
    @State private var volumes = Preferences.driveAliveVolumes
    @State private var mounted = MountedVolumes.all()

    var body: some View {
        Form {
            PaneIntro(intro: Help.Pane.driveAlive)

            Section {
                Toggle("Enable Drive Alive", isOn: $enabled)
                    .help(Help.enableDriveAlive)
                InfoRow(title: intervalTitle, info: Help.driveInterval, isDisabled: !enabled) {
                    Stepper(intervalTitle, value: $interval, in: 1...300)
                }
            }

            Section {
                if mounted.isEmpty {
                    Text("No writable drives found.")
                        .foregroundStyle(.secondary)
                }
                ForEach(mounted) { volume in
                    HStack {
                        Toggle(isOn: isChosen(volume)) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(volume.name)
                                if volume.path == "/" {
                                    Text(Help.internalDrive)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .help(Help.drivePick)
                        Spacer()
                        Picker("", selection: whenToWake(volume)) {
                            Text("During sessions").tag(false)
                            Text("Always").tag(true)
                        }
                        .labelsHidden()
                        .fixedSize()
                        .help(Help.driveWhen)
                        .disabled(!volumes.contains { $0.path == volume.path })
                    }
                    .disabled(!enabled)
                }
            } header: {
                HStack {
                    InfoLabel("Drives", info: Help.driveWhen)
                    Spacer()
                    Button("Refresh") { mounted = MountedVolumes.all() }
                        .controlSize(.small)
                        .help(Help.refreshDrives)
                        .disabled(!enabled)
                }
            }
        }
        .formStyle(.grouped)
        .frame(height: 470)
        .onChange(of: volumes) { _, newValue in Preferences.driveAliveVolumes = newValue }
    }

    private var intervalTitle: String { "Wake drives every \(interval) seconds" }

    private func isChosen(_ volume: DriveAliveVolume) -> Binding<Bool> {
        Binding(
            get: { volumes.contains { $0.path == volume.path } },
            set: { chosen in
                volumes.removeAll { $0.path == volume.path }
                if chosen { volumes.append(volume) }
            }
        )
    }

    private func whenToWake(_ volume: DriveAliveVolume) -> Binding<Bool> {
        Binding(
            get: { volumes.first { $0.path == volume.path }?.always ?? false },
            set: { always in
                guard let index = volumes.firstIndex(where: { $0.path == volume.path }) else { return }
                volumes[index].always = always
            }
        )
    }
}
