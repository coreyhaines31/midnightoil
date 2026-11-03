/// Closed-lid mode stops macOS from locking when the lid shuts, so Midnight Oil locks it instead.
public enum LidLock {
    /// Closed with no external display: nobody can be using the Mac. Docked, it's a desktop,
    /// so locking would get in the way.
    public static func isUnattended(isClosed: Bool, hasExternalDisplay: Bool) -> Bool {
        isClosed && !hasExternalDisplay
    }

    /// Lock on the moment the Mac becomes unattended: the lid closing, or the last external
    /// display unplugging while the lid is already shut. With no earlier reading, as when the lid
    /// shuts before the first check, an unattended Mac locks too: locking a closed Mac costs nothing.
    public static func shouldLock(wasUnattended: Bool?, isUnattended: Bool) -> Bool {
        !(wasUnattended ?? false) && isUnattended
    }
}
