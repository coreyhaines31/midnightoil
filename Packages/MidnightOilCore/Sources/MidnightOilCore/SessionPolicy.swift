import Foundation

/// Rules an organization sets for every session on its Macs. Empty unless
/// Midnight Oil for Teams supplies them.
public struct SessionPolicy: Equatable, Sendable {
    public var disallowsClosedLid: Bool
    /// The longest a session you start yourself may run. Schedules and triggers
    /// are exempt: they end on their own conditions.
    public var maxManualSession: TimeInterval?
    /// Battery level sessions always end below, whatever the user's own setting.
    public var minimumBatteryFloor: Int?

    public static let none = SessionPolicy()

    public init(
        disallowsClosedLid: Bool = false,
        maxManualSession: TimeInterval? = nil,
        minimumBatteryFloor: Int? = nil
    ) {
        self.disallowsClosedLid = disallowsClosedLid
        self.maxManualSession = maxManualSession
        self.minimumBatteryFloor = minimumBatteryFloor
    }

    /// The stricter of the user's battery floor and the organization's.
    public func batteryFloor(user: Int?) -> Int? {
        switch (user, minimumBatteryFloor) {
        case let (user?, minimum?): max(user, minimum)
        case let (user, minimum): user ?? minimum
        }
    }

    /// True once a manual session has run past the organization's limit.
    public func isOverLimit(_ session: Session, at now: Date) -> Bool {
        guard let maxManualSession, session.source == .manual else { return false }
        return now.timeIntervalSince(session.start) >= maxManualSession
    }
}
