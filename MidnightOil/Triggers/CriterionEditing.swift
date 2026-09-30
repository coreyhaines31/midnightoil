import Foundation
import MidnightOilCore

/// The kinds of criteria the editor offers, in menu order.
enum CriterionKind: CaseIterable, Identifiable {
    case wifiNetwork, usbDevice, bluetoothDevice, externalDisplay, powerSource
    case batteryLevel, appRunning, appFrontmost, ipAddress, schedule, idle

    var id: Self { self }

    var title: String {
        switch self {
        case .wifiNetwork: "Wi-Fi Network"
        case .usbDevice: "USB Device"
        case .bluetoothDevice: "Bluetooth Device"
        case .externalDisplay: "External Display"
        case .powerSource: "Power Source"
        case .batteryLevel: "Battery Level"
        case .appRunning: "App Running"
        case .appFrontmost: "App in Front"
        case .ipAddress: "IP Address"
        case .schedule: "Schedule"
        case .idle: "User Activity"
        }
    }

    var defaultCriterion: Criterion {
        switch self {
        case .wifiNetwork: .wifiNetwork([])
        case .usbDevice: .usbDevice([])
        case .bluetoothDevice: .bluetoothDevice([])
        case .externalDisplay: .externalDisplay(connected: true)
        case .powerSource: .powerSource(.powerAdapter)
        case .batteryLevel: .batteryLevel(.atLeast, percent: 20)
        case .appRunning: .appRunning([])
        case .appFrontmost: .appFrontmost([])
        case .ipAddress: .ipAddress(prefixes: [])
        case .schedule: .schedule(Schedule(days: [2, 3, 4, 5, 6], startMinute: 9 * 60, endMinute: 17 * 60))
        case .idle: .idle(.atMost, minutes: 10)
        }
    }
}

extension Criterion {
    var kind: CriterionKind {
        switch self {
        case .wifiNetwork: .wifiNetwork
        case .usbDevice: .usbDevice
        case .bluetoothDevice: .bluetoothDevice
        case .externalDisplay: .externalDisplay
        case .powerSource: .powerSource
        case .batteryLevel: .batteryLevel
        case .appRunning: .appRunning
        case .appFrontmost: .appFrontmost
        case .ipAddress: .ipAddress
        case .schedule: .schedule
        case .idle: .idle
        }
    }

    /// The list of names/IDs for list-based criteria; nil for the others.
    var listValues: [String]? {
        switch self {
        case .wifiNetwork(let values), .usbDevice(let values), .bluetoothDevice(let values),
             .appRunning(let values), .appFrontmost(let values), .ipAddress(let values):
            values
        default:
            nil
        }
    }

    func withListValues(_ values: [String]) -> Criterion {
        switch self {
        case .wifiNetwork: .wifiNetwork(values)
        case .usbDevice: .usbDevice(values)
        case .bluetoothDevice: .bluetoothDevice(values)
        case .appRunning: .appRunning(values)
        case .appFrontmost: .appFrontmost(values)
        case .ipAddress: .ipAddress(prefixes: values)
        default: self
        }
    }

    /// One line for the triggers list, like "Wi-Fi Network: Home".
    var summary: String {
        switch self {
        case .externalDisplay(let connected):
            return connected ? "External display connected" : "No external display"
        case .powerSource(let kind):
            return kind == .battery ? "On battery" : "On power adapter"
        case .batteryLevel(let comparison, let percent):
            return "Battery \(comparison == .atLeast ? "≥" : "≤") \(percent)%"
        case .schedule(let schedule):
            return "Schedule: \(Self.clock(schedule.startMinute))–\(Self.clock(schedule.endMinute))"
        case .idle(let comparison, let minutes):
            return comparison == .atMost ? "Active within \(minutes) min" : "Idle for \(minutes)+ min"
        default:
            let values = listValues ?? []
            return "\(kind.title): \(values.isEmpty ? "—" : values.joined(separator: ", "))"
        }
    }

    private static func clock(_ minutes: Int) -> String {
        let components = DateComponents(hour: minutes / 60, minute: minutes % 60)
        let date = Calendar.current.date(from: components) ?? .now
        return date.formatted(.dateTime.hour().minute())
    }
}
