import Foundation
import MidnightOilTeams

enum TeamsDeviceInfo {
    /// This Mac as Teams reports it: a random id made once, and the organization's label if it set one.
    static func current(defaults: UserDefaults = .standard) -> TeamsDevice {
        let id: String
        if let saved = defaults.string(forKey: TeamsSettingKey.deviceID) {
            id = saved
        } else {
            id = "mac_" + UUID().uuidString.lowercased()
            defaults.set(id, forKey: TeamsSettingKey.deviceID)
        }
        let label = defaults.string(forKey: TeamsSettingKey.deviceLabel).flatMap { $0.isEmpty ? nil : $0 }
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "?"
        return TeamsDevice(id: id, label: label, appVersion: version)
    }
}
