/// Closed-lid mode stops macOS from locking when the lid shuts, so Midnight Oil locks it instead.
public enum LidLock {
    /// With an external display the Mac is in use as a desktop, so locking would get in the way.
    public static func shouldLock(wasClosed: Bool?, isClosed: Bool, hasExternalDisplay: Bool) -> Bool {
        guard let wasClosed else { return false }
        return !wasClosed && isClosed && !hasExternalDisplay
    }
}
