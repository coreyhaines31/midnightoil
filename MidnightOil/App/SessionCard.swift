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

    func update(from session: Session) {
        detail = Self.describe(session)
        allowsDisplaySleep = session.allowsDisplaySleep
        staysAwakeWithLidClosed = session.staysAwakeWithLidClosed
        if case .trigger(_, let name) = session.source {
            triggerLine = "Started by the “\(name)” trigger"
        } else {
            triggerLine = nil
        }
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
            Image(nsImage: LampIcon.menuBarImage(lit: true, size: 26))
                .renderingMode(.template)
                .foregroundStyle(.orange)
                .frame(width: 26, height: 26)

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
                    if showsLidOption {
                        Toggle("Stay awake with lid closed", isOn: Binding(
                            get: { model.staysAwakeWithLidClosed },
                            set: { onStayAwakeWithLidClosed($0) }
                        ))
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
