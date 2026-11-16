import MidnightOilCore
import PanelKit
import SwiftUI

/// What the menu's session card shows. Updated every tick while the menu is open.
@MainActor
@Observable
final class SessionCardModel {
    var detail = ""
    var triggerLine: String?
    var allowsDisplaySleep = false
    var staysAwakeWithLidClosed = false
    var lidPausedForHeat = false
    /// When the session started, for the fascia timestamp and the meter's band.
    var start = Date.now
    /// When the session will end, if it has a known end (time limit, schedule window or policy cutoff).
    var end: Date?
    /// Short end condition for the fascia's detail strip, e.g. "Until 5:00 PM".
    var endSummary = ""
    /// The fascia's instrument for this session.
    var gauge = SessionGauge.reels

    func update(
        from session: Session,
        schedules: [AwakeSchedule],
        policy: SessionPolicy = .none,
        lidPausedForHeat: Bool = false
    ) {
        detail = Self.describe(session)
        start = session.start
        end = session.endDate
        endSummary = Self.summarize(session)
        allowsDisplaySleep = session.allowsDisplaySleep
        staysAwakeWithLidClosed = session.staysAwakeWithLidClosed
        self.lidPausedForHeat = lidPausedForHeat
        var endsWithScheduleWindow = false
        var hasPolicyCutoff = false
        defer {
            gauge = SessionGauge.pick(
                for: session,
                endsWithScheduleWindow: endsWithScheduleWindow,
                hasPolicyCutoff: hasPolicyCutoff
            )
        }
        switch session.source {
        case .trigger(_, let name):
            triggerLine = "Started by the “\(name)” trigger"
        case .schedule(let id, let name):
            triggerLine = "On your “\(name)” schedule"
            if let windowEnd = Self.windowEnd(of: id, in: schedules) {
                let remaining = RemainingTime.detailed(max(0, windowEnd.timeIntervalSinceNow))
                detail = "\(remaining) left · until \(Self.clockTime(windowEnd))"
                end = windowEnd
                endSummary = "Until \(Self.clockTime(windowEnd))"
                endsWithScheduleWindow = true
            }
        case .manual:
            triggerLine = nil
            // An organization's time limit ends manual sessions that would otherwise run longer.
            if let limit = policy.maxManualSession {
                let cutoff = session.start.addingTimeInterval(limit)
                if (session.endDate ?? .distantFuture) > cutoff {
                    detail = "Ends by \(Self.clockTime(cutoff))"
                    triggerLine = "Limit set by your organization"
                    end = cutoff
                    endSummary = "Ends by \(Self.clockTime(cutoff))"
                    hasPolicyCutoff = true
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
        case .whileProcessesRunning(let processes):
            let names = processes.map(\.name)
            return names.count == 1 ? "While “\(names[0])” runs" : "While \(names.count) commands run"
        case .indefinite:
            return "Until you end it"
        case .after, .until:
            guard let endDate = session.endDate, let remaining = session.remaining(at: .now) else { return "" }
            return "\(RemainingTime.detailed(remaining)) left · until \(clockTime(endDate))"
        }
    }

    private static func summarize(_ session: Session) -> String {
        switch session.end {
        case .whileAppRunning(let app): "While \(app.name) runs"
        case .whileDownloading: "While a file downloads"
        case .whileProcessesRunning(let processes):
            processes.count == 1 ? "While a command runs" : "While commands run"
        case .indefinite: "Until you end it"
        case .after, .until: session.endDate.map { "Until \(clockTime($0))" } ?? ""
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

    /// "5:00 PM" today, "Wed 1:00 AM" within the week either side, "Nov 24, 5:00 PM" further out.
    static func clockTime(_ date: Date) -> String {
        ClockTime.format(date)
    }
}

/// The top of the menu while a session runs: the Brushed card with the session's instrument
/// (reels, countdown or 24-hour meter), the countdown and source, and the per-session switches.
struct SessionCardView: View {
    let model: SessionCardModel
    let showsLidOption: Bool
    var displaySleepLocked = false
    var helperInstalled = false
    let onAllowDisplaySleep: @MainActor (Bool) -> Void
    let onStayAwakeWithLidClosed: @MainActor (Bool) -> Void

    var body: some View {
        // TimelineView keeps the instrument current while the menu stays open: every second for the
        // countdown's needle, every 30 seconds for the clock's needle and the reels' minute counter.
        TimelineView(.periodic(from: .now, by: model.gauge == .countdown ? 1 : 30)) { context in
            MenuCard(accent: PanelAccent.midnightOil, appearance: .dark) {
                Fascia(
                    nameplate: "Awake",
                    timestamp: "Since \(SessionCardModel.clockTime(model.start))",
                    detail: model.endSummary,
                    label: "Session"
                ) {
                    gauge(at: context.date)
                }
                Verdict(
                    "Keeping your Mac awake",
                    message: message,
                    status: .go,
                    statusLabel: "Keeping awake"
                )
                .monospacedDigit()
                Row("Allow display sleep", subtitle: displaySleepSubtitle, options: displaySleepLocked ? .dimmed : []) {
                    PanelSwitch(
                        isOn: Binding(get: { model.allowsDisplaySleep }, set: { onAllowDisplaySleep($0) }),
                        accessibilityLabel: "Allow display sleep"
                    )
                    .disabled(displaySleepLocked)
                }
                .help(Help.Menu.allowDisplaySleepShort)
                if showsLidOption {
                    Row("Stay awake with lid closed", subtitle: lidSubtitle) {
                        PanelSwitch(
                            isOn: Binding(
                                get: { model.staysAwakeWithLidClosed },
                                set: { onStayAwakeWithLidClosed($0) }
                            ),
                            accessibilityLabel: "Stay awake with lid closed"
                        )
                    }
                    .help(Help.Menu.staysAwakeWithLidClosed)
                    if model.staysAwakeWithLidClosed, model.lidPausedForHeat {
                        StatusLight(.caution, "Paused while your Mac cools down")
                            .padding(.horizontal, 14)
                            .padding(.bottom, 4)
                            .help(Help.Menu.lidPausedForHeat)
                    }
                }
                Spacer().frame(height: 6)
            }
        }
    }

    private var message: String {
        guard let triggerLine = model.triggerLine else { return model.detail + "." }
        return "\(model.detail). \(triggerLine)."
    }

    @ViewBuilder
    private func gauge(at now: Date) -> some View {
        let end = model.end ?? now
        let elapsed = now.timeIntervalSince(model.start)
        let remaining = max(0, end.timeIntervalSince(now))
        switch model.gauge {
        case .reels:
            ReelGauge(
                elapsed: elapsed,
                isRunning: true,
                caption: "ELAPSED",
                accessibilityValue: "\(RemainingTime.short(elapsed)) awake. \(model.endSummary)."
            )
        case .countdown:
            CountdownMeter(
                total: end.timeIntervalSince(model.start),
                remaining: remaining,
                accessibilityValue: "\(RemainingTime.detailed(remaining)) left. \(model.endSummary)."
            )
        case .clock:
            DayMeter(span: model.start...max(model.start, end), now: now, accessibilityValue: meterValue)
        }
    }

    private var meterValue: String {
        let now = Date.now.formatted(.dateTime.hour().minute())
        return "Now \(now). \(model.endSummary)."
    }

    private var displaySleepSubtitle: String {
        displaySleepLocked ? "Set by your organization" : "The Mac stays awake, the screen can turn off"
    }

    private var lidSubtitle: String {
        helperInstalled ? "Keep working with the lid shut" : "Installs the Closed-Lid Helper once"
    }
}

/// Shown at the top of the idle menu after a session that ran while you were away.
struct LastSessionView: View {
    let record: SessionRecord

    var body: some View {
        MenuCard(accent: PanelAccent.midnightOil, appearance: .dark) {
            Fascia(
                nameplate: "Awake",
                timestamp: "Ended \(SessionCardModel.clockTime(record.end))",
                detail: "\(RemainingTime.short(record.away)) away",
                label: "Last session",
                isLit: false
            ) {
                // At rest: the reels stopped on the last session's length, the face unlit.
                ReelGauge(
                    elapsed: record.awake,
                    isRunning: false,
                    caption: "STOPPED",
                    accessibilityValue: accessibilityValue
                )
            }
            Verdict("While you were away", message: "\(summary). \(ending).", status: .off, statusLabel: "Idle")
        }
    }

    private var accessibilityValue: String {
        "Last session \(SessionCardModel.clockTime(record.start)) to \(SessionCardModel.clockTime(record.end))"
    }

    private var summary: String {
        "Kept working \(RemainingTime.short(record.away)) of a \(RemainingTime.short(record.awake)) session"
    }

    private var ending: String {
        let time = SessionCardModel.clockTime(record.end)
        guard let cause = record.endCause else { return "Ended \(time)" }
        return "Ended \(time)\u{00A0}· \(cause.label)"
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
