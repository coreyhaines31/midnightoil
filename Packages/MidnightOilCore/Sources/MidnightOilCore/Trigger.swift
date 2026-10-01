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
    /// The trigger that should be keeping the Mac awake right now: the one already
    /// `running` while it still matches, otherwise the first match. `suppressed` holds
    /// triggers the user ended by hand; each stays quiet until it stops matching.
    public static func activeTrigger(
        in triggers: [Trigger],
        state: SystemState,
        suppressed: Set<UUID>,
        running: UUID? = nil
    ) -> Trigger? {
        let candidates = triggers.filter { !suppressed.contains($0.id) && $0.matches(state) }
        return candidates.first { $0.id == running } ?? candidates.first
    }

    /// The suppressed triggers that should stay quiet: those that still match.
    /// One that stopped matching, or was deleted, re-arms.
    public static func stillSuppressed(_ suppressed: Set<UUID>, triggers: [Trigger], state: SystemState) -> Set<UUID> {
        suppressed.filter { id in triggers.first { $0.id == id }?.matches(state) == true }
    }
}
