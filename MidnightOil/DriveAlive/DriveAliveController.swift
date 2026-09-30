import Foundation
import os

/// Keeps chosen disks from spinning down by touching a hidden file on them.
/// Runs during sessions, or always for volumes marked that way.
@MainActor
final class DriveAliveController {
    private static let logger = Logger(subsystem: "app.midnightoil.MidnightOil", category: "DriveAlive")
    private static let fileName = ".midnightoil-drive-alive"

    private let sessions: SessionController
    private var ticker: Task<Void, Never>?

    init(sessions: SessionController) {
        self.sessions = sessions
        ticker = Task { [weak self] in
            while !Task.isCancelled {
                self?.tick()
                let seconds = max(1, Preferences.driveAliveInterval)
                try? await Task.sleep(for: .seconds(seconds))
            }
        }
    }

    private func tick() {
        guard Preferences.driveAliveEnabled else { return }
        for volume in Preferences.driveAliveVolumes where volume.always || sessions.isActive {
            touch(URL(filePath: volume.path).appending(path: Self.fileName))
        }
    }

    private func touch(_ file: URL) {
        let stamp = Data(Date.now.formatted(.iso8601).utf8)
        do {
            try stamp.write(to: file, options: .atomic)
        } catch {
            let reason = error.localizedDescription
            Self.logger.error("Couldn't touch \(file.path, privacy: .public): \(reason, privacy: .public)")
        }
    }
}

struct DriveAliveVolume: Codable, Equatable, Identifiable {
    var path: String
    var always: Bool

    var id: String { path }
    var name: String { URL(filePath: path).lastPathComponent }
}

enum MountedVolumes {
    /// Local, browsable volumes the user can choose from.
    static func all() -> [DriveAliveVolume] {
        let keys: [URLResourceKey] = [.volumeNameKey, .volumeIsBrowsableKey, .volumeIsReadOnlyKey]
        let urls = FileManager.default.mountedVolumeURLs(
            includingResourceValuesForKeys: keys,
            options: [.skipHiddenVolumes]
        ) ?? []
        return urls.compactMap { url in
            guard let values = try? url.resourceValues(forKeys: Set(keys)),
                  values.volumeIsBrowsable == true,
                  values.volumeIsReadOnly != true
            else { return nil }
            return DriveAliveVolume(path: url.path(percentEncoded: false), always: false)
        }
    }
}
