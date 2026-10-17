import ServiceManagement

/// Midnight Oil launches at login out of the box. Applied once, so turning it off in Settings sticks.
enum LaunchAtLoginDefault {
    private static let appliedKey = "appliedLaunchAtLoginDefault"

    static func applyOnce() {
        // A debug build would register its build folder copy as the login item.
        #if !DEBUG
        let defaults = UserDefaults.standard
        guard !defaults.bool(forKey: appliedKey) else { return }
        defaults.set(true, forKey: appliedKey)
        try? SMAppService.mainApp.register()
        #endif
    }
}
