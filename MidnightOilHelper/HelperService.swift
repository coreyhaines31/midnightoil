import Foundation

/// Accepts XPC connections from the Midnight Oil app only, and releases a
/// connection's hold on sleep the moment it goes away (quit, crash, or kill).
final class HelperService: NSObject, NSXPCListenerDelegate, @unchecked Sendable {
    private let sleep: SleepController

    init(sleep: SleepController) {
        self.sleep = sleep
    }

    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection connection: NSXPCConnection) -> Bool {
        connection.setCodeSigningRequirement(HelperConstants.clientRequirement)
        connection.exportedInterface = NSXPCInterface(with: HelperProtocol.self)

        let holder = ObjectIdentifier(connection)
        connection.exportedObject = ConnectionHandler(holder: holder, sleep: sleep)
        let release: @Sendable () -> Void = { [sleep] in
            _ = sleep.setSleepDisabled(false, for: holder)
        }
        connection.invalidationHandler = release
        connection.interruptionHandler = release
        connection.resume()
        return true
    }
}

private final class ConnectionHandler: NSObject, HelperProtocol, @unchecked Sendable {
    private let holder: ObjectIdentifier
    private let sleep: SleepController

    init(holder: ObjectIdentifier, sleep: SleepController) {
        self.holder = holder
        self.sleep = sleep
    }

    func setSleepDisabled(_ disabled: Bool, reply: @escaping @Sendable (Bool) -> Void) {
        reply(sleep.setSleepDisabled(disabled, for: holder))
    }
}
