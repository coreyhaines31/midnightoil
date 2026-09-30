import SwiftUI

struct DriveAliveSettingsView: View {
    @AppStorage(Preferences.Key.driveAliveEnabled) private var enabled = false
    @AppStorage(Preferences.Key.driveAliveInterval) private var interval = 10
    @State private var volumes = Preferences.driveAliveVolumes
    @State private var mounted = MountedVolumes.all()

    var body: some View {
        Form {
            Section {
                Toggle("Enable Drive Alive", isOn: $enabled)
                Stepper(value: $interval, in: 1...300) {
                    Text("Wake drives every \(interval) seconds")
                }
                .disabled(!enabled)
            } footer: {
                Text("Writes a tiny hidden file to each chosen drive so it doesn't spin down.")
                    .foregroundStyle(.secondary)
            }

            Section {
                if mounted.isEmpty {
                    Text("No writable drives found.")
                        .foregroundStyle(.secondary)
                }
                ForEach(mounted) { volume in
                    HStack {
                        Toggle(volume.name, isOn: isChosen(volume))
                        Spacer()
                        Picker("", selection: whenToWake(volume)) {
                            Text("During sessions").tag(false)
                            Text("Always").tag(true)
                        }
                        .labelsHidden()
                        .fixedSize()
                        .disabled(!volumes.contains { $0.path == volume.path })
                    }
                }
            } header: {
                HStack {
                    Text("Drives")
                    Spacer()
                    Button("Refresh") { mounted = MountedVolumes.all() }
                        .controlSize(.small)
                }
            }
            .disabled(!enabled)
        }
        .formStyle(.grouped)
        .frame(height: 380)
        .onChange(of: volumes) { _, newValue in Preferences.driveAliveVolumes = newValue }
    }

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
