import Foundation

enum HelperConstants {
    static let machServiceName = "app.midnightoil.MidnightOil.Helper"
    static let plistName = "app.midnightoil.MidnightOil.Helper.plist"
    /// Only the signed Midnight Oil app may talk to the root helper.
    static let clientRequirement = """
        identifier "app.midnightoil.MidnightOil" and anchor apple generic \
        and certificate leaf[subject.OU] = "KPQU8X839X"
        """
}

/// XPC interface of the privileged helper that keeps a Mac awake with its lid closed.
@objc protocol HelperProtocol {
    /// Turns lid-close sleep off (true) or back on (false) for this connection.
    /// Sleep stays disabled while any connection wants it, and is restored
    /// automatically when a connection drops.
    func setSleepDisabled(_ disabled: Bool, reply: @escaping @Sendable (Bool) -> Void)
}
