import Foundation

/// A snapshot of everything triggers can look at. The app fills this in from
/// the system; Core only compares against it, which keeps the rules testable.
public struct SystemState: Equatable, Sendable {
    public var wifiNetwork: String?
    public var usbDevices: Set<String>
    public var bluetoothDevices: Set<String>
    public var externalDisplayCount: Int
    public var power: PowerState
    public var runningApps: Set<String>
    public var frontmostApp: String?
    public var ipAddresses: [String]
    public var idleSeconds: TimeInterval
    public var date: Date
    public var calendar: Calendar

    public init(
        wifiNetwork: String? = nil,
        usbDevices: Set<String> = [],
        bluetoothDevices: Set<String> = [],
        externalDisplayCount: Int = 0,
        power: PowerState = PowerState(batteryPercent: nil, isOnBattery: false),
        runningApps: Set<String> = [],
        frontmostApp: String? = nil,
        ipAddresses: [String] = [],
        idleSeconds: TimeInterval = 0,
        date: Date = .now,
        calendar: Calendar = .current
    ) {
        self.wifiNetwork = wifiNetwork
        self.usbDevices = usbDevices
        self.bluetoothDevices = bluetoothDevices
        self.externalDisplayCount = externalDisplayCount
        self.power = power
        self.runningApps = runningApps
        self.frontmostApp = frontmostApp
        self.ipAddresses = ipAddresses
        self.idleSeconds = idleSeconds
        self.date = date
        self.calendar = calendar
    }
}
