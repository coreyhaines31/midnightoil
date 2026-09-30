import SwiftUI

struct DriveAliveSettingsView: View {
    @AppStorage(Preferences.Key.driveAliveEnabled) private var enabled = false
    @AppStorage(Preferences.Key.driveAliveInterval) private var interval = 10
    @State private var volumes = Preferences.driveAliveVolumes
    @State private var mounted = MountedVolumes.all()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle("Enable Drive Alive", isOn: $enabled)
            Text("Writes a tiny hidden file to each chosen drive so it never spins down during a session.")
                .font(.callout)
                .foregroundStyle(.secondary)

            Table(mounted) {
                TableColumn("Drive") { volume in
                    Toggle(volume.name, isOn: binding(for: volume) { $0 != nil } set: { include, current in
                        include ? (current ?? volume) : nil
                    })
                }
                TableColumn("Always keep alive") { volume in
                    Toggle("", isOn: binding(for: volume) { $0?.always == true } set: { always, current in
                        current.map { var updated = $0; updated.always = always; return updated }
                    })
                    .labelsHidden()
                    .disabled(!volumes.contains { $0.path == volume.path })
                }
                .width(140)
            }
            .overlay {
                if mounted.isEmpty {
                    Text("No writable drives found.").foregroundStyle(.secondary)
                }
            }
            .disabled(!enabled)

            HStack {
                Stepper(value: $interval, in: 1...300) {
                    Text("Wake drives every \(interval) seconds")
                }
                Spacer()
                Button("Refresh") { mounted = MountedVolumes.all() }
            }
            .disabled(!enabled)
        }
        .padding()
        .onChange(of: volumes) { _, newValue in Preferences.driveAliveVolumes = newValue }
    }

    /// Binds a table row to its entry in the chosen-volumes list (nil = not chosen).
    private func binding(
        for volume: DriveAliveVolume,
        get: @escaping (DriveAliveVolume?) -> Bool,
        set: @escaping (Bool, DriveAliveVolume?) -> DriveAliveVolume?
    ) -> Binding<Bool> {
        Binding(
            get: { get(volumes.first { $0.path == volume.path }) },
            set: { value in
                let current = volumes.first { $0.path == volume.path }
                volumes.removeAll { $0.path == volume.path }
                if let updated = set(value, current) { volumes.append(updated) }
            }
        )
    }
}
