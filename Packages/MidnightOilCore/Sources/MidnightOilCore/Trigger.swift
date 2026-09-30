import Foundation

/// Starts a session on its own while every criterion holds.
public struct Trigger: Codable, Identifiable, Equatable, Sendable {
    public var id: UUID
    public var name: String
    public var isEnabled: Bool
    public var criteria: [Criterion]
    public var allowsDisplaySleep: Bool
    public var staysAwakeWithLidClosed: Bool

    public init(
        id: UUID = UUID(),
        name: String,
        isEnabled: Bool = true,
        criteria: [Criterion],
        allowsDisplaySleep: Bool = false,
        staysAwakeWithLidClosed: Bool = false
    ) {
        self.id = id
        self.name = name
        self.isEnabled = isEnabled
        self.criteria = criteria
        self.allowsDisplaySleep = allowsDisplaySleep
        self.staysAwakeWithLidClosed = staysAwakeWithLidClosed
    }

    /// A trigger with no criteria never fires; that's a half-edited trigger, not "always".
    public func matches(_ state: SystemState) -> Bool {
        isEnabled && !criteria.isEmpty && criteria.allSatisfy { $0.matches(state) }
    }
}

public enum TriggerEngine {
    /// The first trigger that should be keeping the Mac awake right now.
    /// `suppressed` is a trigger the user ended by hand; it stays quiet until it stops matching.
    public static func activeTrigger(in triggers: [Trigger], state: SystemState, suppressed: UUID?) -> Trigger? {
        triggers.first { $0.id != suppressed && $0.matches(state) }
    }

    /// Whether a suppressed trigger can be re-armed: once its criteria no longer hold.
    public static func canRearm(_ suppressed: UUID?, triggers: [Trigger], state: SystemState) -> Bool {
        guard let suppressed, let trigger = triggers.first(where: { $0.id == suppressed }) else { return true }
        return !trigger.matches(state)
    }
}
