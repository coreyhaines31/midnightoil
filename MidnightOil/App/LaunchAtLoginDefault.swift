import ServiceManagement

/// Midnight Oil launches at login out of the box. Applied once, so turning it off in Settings sticks.
enum LaunchAtLoginDefault {
    private static let appliedKey = "appliedLaunchAtLoginDefault"

    static func applyOnce() {
        // A debug build would register its build folder copy as the login item.
        #if !DEBUG
        let defaults = UserDefaults.standard
        guard !defaults.bool(forKey: appliedKey) else { return }
        // Only once it took, so a failed attempt (say, run from a disk image) tries again next launch.
        guard (try? SMAppService.mainApp.register()) != nil else { return }
        defaults.set(true, forKey: appliedKey)
        #endif
    }
}
