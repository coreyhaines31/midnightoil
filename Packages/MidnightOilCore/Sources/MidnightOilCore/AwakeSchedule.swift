import Foundation

/// Keeps the Mac awake during set hours, like "Work hours, Mon–Fri 9–5".
/// Evaluated by the trigger engine as a trigger: the schedule plus any extra conditions.
public struct AwakeSchedule: Codable, Identifiable, Equatable, Sendable {
    public var id: UUID
    public var name: String
    public var isEnabled: Bool
    public var schedule: Schedule
    /// Extra conditions that must also hold, like being plugged in. Empty = the whole window.
    public var conditions: [Criterion]
    public var allowsDisplaySleep: Bool
    public var staysAwakeWithLidClosed: Bool

    public init(
        id: UUID = UUID(),
        name: String,
        isEnabled: Bool = true,
        schedule: Schedule,
        conditions: [Criterion] = [],
        allowsDisplaySleep: Bool = false,
        staysAwakeWithLidClosed: Bool = false
    ) {
        self.id = id
        self.name = name
        self.isEnabled = isEnabled
        self.schedule = schedule
        self.conditions = conditions
        self.allowsDisplaySleep = allowsDisplaySleep
        self.staysAwakeWithLidClosed = staysAwakeWithLidClosed
    }

    public var asTrigger: Trigger {
        Trigger(
            id: id,
            name: name,
            isEnabled: isEnabled,
            criteria: [.schedule(schedule)] + conditions,
            allowsDisplaySleep: allowsDisplaySleep,
            staysAwakeWithLidClosed: staysAwakeWithLidClosed
        )
    }

    public static let workHours = AwakeSchedule(
        name: "Work hours",
        schedule: Schedule(days: [2, 3, 4, 5, 6], startMinute: 9 * 60, endMinute: 17 * 60)
    )

    public static let overnight = AwakeSchedule(
        name: "Overnight",
        schedule: Schedule(days: [1, 2, 3, 4, 5, 6, 7], startMinute: 23 * 60, endMinute: 7 * 60),
        allowsDisplaySleep: true
    )
}
