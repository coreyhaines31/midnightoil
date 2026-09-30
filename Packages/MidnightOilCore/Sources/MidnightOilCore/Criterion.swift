import Foundation

public enum Comparison: String, Codable, CaseIterable, Sendable {
    case atLeast
    case atMost
}

public enum PowerSourceKind: String, Codable, CaseIterable, Sendable {
    case battery
    case powerAdapter
}

/// Days use `Calendar` numbering: 1 = Sunday … 7 = Saturday. Minutes count
/// from midnight; an end before the start wraps past midnight.
public struct Schedule: Codable, Equatable, Sendable {
    public var days: Set<Int>
    public var startMinute: Int
    public var endMinute: Int

    public init(days: Set<Int>, startMinute: Int, endMinute: Int) {
        self.days = days
        self.startMinute = startMinute
        self.endMinute = endMinute
    }

    func contains(_ date: Date, calendar: Calendar) -> Bool {
        let parts = calendar.dateComponents([.weekday, .hour, .minute], from: date)
        guard let weekday = parts.weekday, let hour = parts.hour, let minute = parts.minute else { return false }
        let now = hour * 60 + minute
        if startMinute <= endMinute {
            return days.contains(weekday) && now >= startMinute && now < endMinute
        }
        // Overnight: tonight's stretch counts for today, the early-morning tail for the day before.
        if now >= startMinute { return days.contains(weekday) }
        let yesterday = weekday == 1 ? 7 : weekday - 1
        return now < endMinute && days.contains(yesterday)
    }
}

/// One condition inside a trigger. Lists match if any entry matches.
public enum Criterion: Codable, Equatable, Sendable {
    case wifiNetwork([String])
    case usbDevice([String])
    case bluetoothDevice([String])
    case externalDisplay(connected: Bool)
    case powerSource(PowerSourceKind)
    case batteryLevel(Comparison, percent: Int)
    case appRunning([String])
    case appFrontmost([String])
    case ipAddress(prefixes: [String])
    case schedule(Schedule)
    case idle(Comparison, minutes: Int)

    // One straightforward branch per criterion; splitting it up would only hide the mapping.
    // swiftlint:disable:next cyclomatic_complexity
    public func matches(_ state: SystemState) -> Bool {
        switch self {
        case .wifiNetwork(let names):
            guard let network = state.wifiNetwork else { return false }
            return names.contains(network)
        case .usbDevice(let names):
            return !state.usbDevices.isDisjoint(with: names)
        case .bluetoothDevice(let names):
            return !state.bluetoothDevices.isDisjoint(with: names)
        case .externalDisplay(let connected):
            return (state.externalDisplayCount > 0) == connected
        case .powerSource(let kind):
            return state.power.isOnBattery == (kind == .battery)
        case .batteryLevel(let comparison, let percent):
            guard let level = state.power.batteryPercent else { return false }
            return comparison == .atLeast ? level >= percent : level <= percent
        case .appRunning(let bundleIDs):
            return !state.runningApps.isDisjoint(with: bundleIDs)
        case .appFrontmost(let bundleIDs):
            guard let frontmost = state.frontmostApp else { return false }
            return bundleIDs.contains(frontmost)
        case .ipAddress(let prefixes):
            return state.ipAddresses.contains { address in prefixes.contains { address.hasPrefix($0) } }
        case .schedule(let schedule):
            return schedule.contains(state.date, calendar: state.calendar)
        case .idle(let comparison, let minutes):
            let idleMinutes = state.idleSeconds / 60
            return comparison == .atLeast ? idleMinutes >= Double(minutes) : idleMinutes <= Double(minutes)
        }
    }
}
