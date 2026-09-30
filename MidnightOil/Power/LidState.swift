import Foundation
import IOKit

enum LidState {
    /// Whether the built-in display's lid is shut. Nil on Macs without a lid.
    static func isClosed() -> Bool? {
        let rootDomain = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching("IOPMrootDomain"))
        guard rootDomain != IO_OBJECT_NULL else { return nil }
        defer { IOObjectRelease(rootDomain) }
        let property = IORegistryEntryCreateCFProperty(
            rootDomain,
            "AppleClamshellState" as CFString,
            kCFAllocatorDefault,
            0
        )
        return property?.takeRetainedValue() as? Bool
    }

    static var hasLid: Bool { isClosed() != nil }
}
