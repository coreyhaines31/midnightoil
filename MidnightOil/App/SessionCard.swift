import MidnightOilCore
import SwiftUI

/// What the menu's session card shows. Updated every tick while the menu is open.
@MainActor
@Observable
final class SessionCardModel {
    var detail = ""
    var triggerLine: String?
    var allowsDisplaySleep = false
    var staysAwakeWithLidClosed = false

    func update(from session: Session, schedules: [AwakeSchedule], policy: SessionPolicy = .none) {
        detail = Self.describe(session)
        allowsDisplaySleep = session.allowsDisplaySleep
        staysAwakeWithLidClosed = session.staysAwakeWithLidClosed
        switch session.source {
        case .trigger(_, let name):
            triggerLine = "Started by the “\(name)” trigger"
        case .schedule(let id, let name):
            triggerLine = "On your “\(name)” schedule"
            if let end = Self.windowEnd(of: id, in: schedules) {
                let remaining = RemainingTime.detailed(max(0, end.timeIntervalSinceNow))
                detail = "\(remaining) left · until \(Self.clockTime(end))"
            }
        case .manual:
            triggerLine = nil
            // An organization's time limit ends manual sessions that would otherwise run longer.
            if let limit = policy.maxManualSession {
                let cutoff = session.start.addingTimeInterval(limit)
                if (session.endDate ?? .distantFuture) > cutoff {
                    detail = "Ends by \(Self.clockTime(cutoff))"
                    triggerLine = "Limit set by your organization"
                }
            }
        }
    }

    /// When the running schedule's current window closes.
    static func windowEnd(of id: UUID, in schedules: [AwakeSchedule]) -> Date? {
        schedules.first { $0.id == id }?.schedule.windowEnd(containing: .now, calendar: .current)
    }

    private static func describe(_ session: Session) -> String {
        switch session.end {
        case .whileAppRunning(let app):
            return "While \(app.name) is running"
        case .whileDownloading(let file):
            return "While “\(DownloadProgress.displayName(for: file))” downloads"
        case .indefinite:
            return "Until you end it"
        case .after, .until:
            guard let endDate = session.endDate, let remaining = session.remaining(at: .now) else { return "" }
            return "\(RemainingTime.detailed(remaining)) left · until \(clockTime(endDate))"
        }
    }

    /// "9:00 AM" today, "Tomorrow 9:00 AM", "Mon 9:00 AM" this week, "Oct 8, 9:00 AM" beyond.
    /// For schedule times, which can be a week away on the same weekday.
    static func upcomingTime(_ date: Date) -> String {
        let calendar = Calendar.current
        let time = date.formatted(.dateTime.hour().minute())
        if calendar.isDateInToday(date) { return time }
        if calendar.isDateInTomorrow(date) { return "Tomorrow \(time)" }
        let days = calendar.dateComponents([.day], from: calendar.startOfDay(for: .now), to: date).day ?? 0
        if days < 7 { return date.formatted(.dateTime.weekday(.abbreviated).hour().minute()) }
        return date.formatted(.dateTime.month(.abbreviated).day().hour().minute())
    }

    /// "5:00 PM" today, "Wed 1:00 AM" on another day.
    static func clockTime(_ date: Date) -> String {
        date.formatted(Calendar.current.isDateInToday(date)
            ? .dateTime.hour().minute()
            : .dateTime.weekday(.abbreviated).hour().minute())
    }
}

/// The top of the menu while a session runs: status, countdown, and per-session options.
struct SessionCardView: View {
    let model: SessionCardModel
    let showsLidOption: Bool
    let onAllowDisplaySleep: @MainActor (Bool) -> Void
    let onStayAwakeWithLidClosed: @MainActor (Bool) -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(nsImage: FlameIcon.menuBarImage(lit: true, size: 24))
                .renderingMode(.template)
                .foregroundStyle(.orange)
                .frame(width: 24, height: 24)
                .padding(.top, 1)

            VStack(alignment: .leading, spacing: 2) {
                Text("Keeping your Mac awake")
                    .font(.system(size: 13, weight: .semibold))
                Text(model.detail)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
                if let triggerLine = model.triggerLine {
                    Text(triggerLine)
                        .font(.system(size: 11))
                        .foregroundStyle(.tertiary)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Toggle("Allow display sleep", isOn: Binding(
                        get: { model.allowsDisplaySleep },
                        set: { onAllowDisplaySleep($0) }
                    ))
                    .help(Help.Menu.allowDisplaySleepShort)
                    if showsLidOption {
                        Toggle("Stay awake with lid closed", isOn: Binding(
                            get: { model.staysAwakeWithLidClosed },
                            set: { onStayAwakeWithLidClosed($0) }
                        ))
                        .help(Help.Menu.staysAwakeWithLidClosed)
                    }
                }
                .toggleStyle(.checkbox)
                .controlSize(.small)
                .font(.system(size: 12))
                .padding(.top, 6)
            }
            Spacer(minLength: 0)
        }
        .padding(.leading, 14)
        .padding(.trailing, 16)
        .padding(.top, 4)
        .padding(.bottom, 6)
        .frame(width: 290, alignment: .leading)
    }
}

/// Shown at the top of the idle menu after a session that ran while you were away.
struct LastSessionView: View {
    let record: SessionRecord

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(nsImage: FlameIcon.menuBarImage(lit: false, size: 20))
                .renderingMode(.template)
                .foregroundStyle(.secondary)
                .frame(width: 24, height: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text("While you were away")
                    .font(.system(size: 13, weight: .semibold))
                Text(summary)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                Text(ending)
                    .font(.system(size: 11))
                    .foregroundStyle(.tertiary)
            }
            Spacer(minLength: 0)
        }
        .padding(.leading, 14)
        .padding(.trailing, 16)
        .padding(.vertical, 4)
        .frame(width: 290, alignment: .leading)
    }

    private var summary: String {
        "Kept working \(RemainingTime.short(record.away)) of a \(RemainingTime.short(record.awake)) session"
    }

    private var ending: String {
        let time = SessionCardModel.clockTime(record.end)
        guard let cause = record.endCause else { return "Ended \(time)" }
        return "Ended \(time) · \(cause.label)"
    }

    /// The last session worth recapping: recent, and mostly unattended.
    static func recap(from records: [SessionRecord], now: Date = .now) -> SessionRecord? {
        guard let last = records.last,
              now.timeIntervalSince(last.end) < 18 * 3_600,
              last.away >= 10 * 60
        else { return nil }
        return last
    }
}
