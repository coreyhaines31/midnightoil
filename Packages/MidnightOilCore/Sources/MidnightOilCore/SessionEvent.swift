/// Something that happened to a session, for Midnight Oil for Teams to report.
public enum SessionEvent: Equatable, Sendable {
    case started(Session)
    /// Every ending, including a session replaced by a new one.
    case ended(Session, SessionRecord)
}
