import IOKit.pwr_mgt
import MidnightOilCore
import os

/// Holds the IOKit power assertions that keep the Mac awake. They show up by
/// name in `pmset -g assertions`.
@MainActor
final class AssertionManager {
    private static let systemSleepType = "PreventUserIdleSystemSleep"
    private static let displaySleepType = "PreventUserIdleDisplaySleep"
    private static let logger = Logger(subsystem: "app.midnightoil.MidnightOil", category: "Assertions")

    private var systemAssertion: IOPMAssertionID?
    private var displayAssertion: IOPMAssertionID?

    func apply(keepAwake: Bool, allowsDisplaySleep: Bool) {
        systemAssertion = update(systemAssertion, wanted: keepAwake, type: Self.systemSleepType)
        displayAssertion = update(
            displayAssertion,
            wanted: keepAwake && !allowsDisplaySleep,
            type: Self.displaySleepType
        )
    }

    func releaseAll() {
        apply(keepAwake: false, allowsDisplaySleep: true)
    }

    private func update(_ current: IOPMAssertionID?, wanted: Bool, type: String) -> IOPMAssertionID? {
        guard wanted else {
            if let current { IOPMAssertionRelease(current) }
            return nil
        }
        if let current { return current }

        var id = IOPMAssertionID(0)
        let result = IOPMAssertionCreateWithName(
            type as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            Brand.assertionReason as CFString,
            &id
        )
        guard result == kIOReturnSuccess else {
            Self.logger.error("Failed to create \(type) assertion: \(result)")
            return nil
        }
        return id
    }
}
