import CoreGraphics
import Foundation
import os

/// Locks the screen the way Control-Command-Q does. macOS has no public call for this, so it
/// uses the login framework's SACLockScreenImmediate, looked up at runtime so a missing symbol
/// only disables the feature.
enum ScreenLocker {
    private typealias LockFunction = @convention(c) () -> Int32
    private static let logger = Logger(subsystem: "app.midnightoil.MidnightOil", category: "ScreenLocker")

    private static let lockFunction: LockFunction? = {
        guard let handle = dlopen("/System/Library/PrivateFrameworks/login.framework/login", RTLD_LAZY),
              let symbol = dlsym(handle, "SACLockScreenImmediate") else { return nil }
        return unsafeBitCast(symbol, to: LockFunction.self)
    }()

    static func lock() {
        guard let lockFunction else {
            logger.error("SACLockScreenImmediate is unavailable")
            return
        }
        let result = lockFunction()
        if result != 0 { logger.error("SACLockScreenImmediate returned \(result)") }
    }

    /// Whether a display other than the built-in one is on, i.e. the Mac is docked.
    static func hasExternalDisplay() -> Bool {
        var count: UInt32 = 0
        guard CGGetActiveDisplayList(0, nil, &count) == .success else { return false }
        var displays = [CGDirectDisplayID](repeating: 0, count: Int(count))
        guard CGGetActiveDisplayList(count, &displays, &count) == .success else { return false }
        return displays.prefix(Int(count)).contains { CGDisplayIsBuiltin($0) == 0 }
    }
}
