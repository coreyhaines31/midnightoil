import Foundation
import MidnightOilCore

/// Carries out what the `midnightoil` command asks for, the same way the menu would.
@MainActor
final class CLICommands {
    private let sessions: SessionController
    private let schedules: ScheduleStore
    private let expectedEnd: (Session) -> Date?

    init(sessions: SessionController, schedules: ScheduleStore, expectedEnd: @escaping (Session) -> Date?) {
        self.sessions = sessions
        self.schedules = schedules
        self.expectedEnd = expectedEnd
    }

    func handle(_ request: CLIRequest) -> CLIResponse {
        var notes: [String] = []
        switch request.action {
        case .status:
            break
        case .stop:
            if sessions.isActive {
                sessions.end(reason: .user)
            } else {
                notes.append("Nothing to stop: Midnight Oil wasn't keeping your Mac awake.")
            }
        case .start:
            if let end = request.sessionEnd {
                start(end, request: request, notes: &notes)
            }
        }
        return CLIResponse(notes: notes, status: status())
    }

    private func start(_ end: SessionEnd, request: CLIRequest, notes: inout [String]) {
        let wantsLid = request.staysAwakeWithLidClosed ?? Preferences.staysAwakeWithLidClosed
        if wantsLid, !sessions.canUseLidMode {
            notes.append(sessions.policy().disallowsClosedLid
                ? "Your organization turned off closed-lid mode, so your Mac will sleep if you close the lid."
                : "Closed-lid mode isn't set up, so your Mac will sleep if you close the lid. "
                    + "Set it up once in Midnight Oil's Settings › Closed Lid.")
        }
        // Runs share one session, so parallel agents keep the Mac awake until the last finishes.
        if case .whileProcessesRunning(let processes) = end, let current = sessions.session {
            switch current.end {
            case .whileProcessesRunning:
                processes.forEach(sessions.join)
                if wantsLid, sessions.canUseLidMode, !current.staysAwakeWithLidClosed {
                    sessions.setStaysAwakeWithLidClosed(true)
                }
                return
            case .indefinite where current.source == .manual:
                // Already awake until you end it; a run shouldn't cut that short.
                if wantsLid, sessions.canUseLidMode, !current.staysAwakeWithLidClosed {
                    sessions.setStaysAwakeWithLidClosed(true)
                }
                notes.append("Your Mac was already staying awake until you end it, so that session keeps running.")
                return
            default:
                break
            }
        }
        sessions.start(end, allowsDisplaySleep: request.allowsDisplaySleep, staysAwakeWithLidClosed: wantsLid)
    }

    private func status() -> CLIStatus {
        guard let session = sessions.session else { return .asleep }
        let card = SessionCardModel()
        card.update(from: session, schedules: schedules.schedules, policy: sessions.policy())
        var startedBy = "you"
        switch session.source {
        case .trigger(_, let name): startedBy = "the “\(name)” trigger"
        case .schedule(_, let name): startedBy = "your “\(name)” schedule"
        case .manual: break
        }
        var processes: [String]?
        if case .whileProcessesRunning(let watched) = session.end {
            processes = watched.map(\.name)
        }
        return CLIStatus(
            awake: true,
            detail: card.detail,
            startedBy: startedBy,
            started: session.start,
            ends: expectedEnd(session),
            staysAwakeWithLidClosed: session.staysAwakeWithLidClosed,
            allowsDisplaySleep: session.allowsDisplaySleep,
            processes: processes
        )
    }
}
