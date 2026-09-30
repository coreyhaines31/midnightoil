import AppKit
import CoreWLAN
import Darwin
import IOBluetooth
import IOKit
import MidnightOilCore

/// Builds the snapshot triggers are evaluated against. Radios are only queried
/// when a trigger actually uses them, so users who never touch Wi-Fi or
/// Bluetooth criteria are never asked for those permissions.
enum SystemStateReader {
    struct Needs {
        var wifi = false
        var usb = false
        var bluetooth = false
    }

    @MainActor
    static func current(needs: Needs) -> SystemState {
        let running = NSWorkspace.shared.runningApplications
        return SystemState(
            wifiNetwork: needs.wifi ? wifiNetwork() : nil,
            usbDevices: needs.usb ? usbDeviceNames() : [],
            bluetoothDevices: needs.bluetooth ? bluetoothDeviceNames() : [],
            externalDisplayCount: externalDisplayCount(),
            power: PowerSourceReader.current(),
            runningApps: Set(running.compactMap(\.bundleIdentifier)),
            frontmostApp: NSWorkspace.shared.frontmostApplication?.bundleIdentifier,
            ipAddresses: ipv4Addresses(),
            idleSeconds: idleSeconds()
        )
    }

    static func wifiNetwork() -> String? {
        CWWiFiClient.shared().interface()?.ssid()
    }

    static func usbDeviceNames() -> Set<String> {
        var iterator: io_iterator_t = 0
        let matching = IOServiceMatching("IOUSBHostDevice")
        guard IOServiceGetMatchingServices(kIOMainPortDefault, matching, &iterator) == KERN_SUCCESS else { return [] }
        defer { IOObjectRelease(iterator) }

        var names = Set<String>()
        var device = IOIteratorNext(iterator)
        while device != IO_OBJECT_NULL {
            let key = "USB Product Name" as CFString
            let property = IORegistryEntryCreateCFProperty(device, key, kCFAllocatorDefault, 0)
            if let name = property?.takeRetainedValue() as? String, !name.isEmpty {
                names.insert(name)
            }
            IOObjectRelease(device)
            device = IOIteratorNext(iterator)
        }
        return names
    }

    static func bluetoothDeviceNames() -> Set<String> {
        let paired = IOBluetoothDevice.pairedDevices() as? [IOBluetoothDevice] ?? []
        return Set(paired.filter { $0.isConnected() }.compactMap(\.name))
    }

    /// Names of every paired Bluetooth device, connected or not, for the trigger editor.
    static func pairedBluetoothDeviceNames() -> [String] {
        let paired = IOBluetoothDevice.pairedDevices() as? [IOBluetoothDevice] ?? []
        return paired.compactMap(\.name).sorted()
    }

    @MainActor
    static func externalDisplayCount() -> Int {
        NSScreen.screens.filter { screen in
            guard let number = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID
            else { return false }
            return CGDisplayIsBuiltin(number) == 0
        }.count
    }

    static func ipv4Addresses() -> [String] {
        var addresses: [String] = []
        var list: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&list) == 0, let first = list else { return [] }
        defer { freeifaddrs(list) }

        for pointer in sequence(first: first, next: { $0.pointee.ifa_next }) {
            let interface = pointer.pointee
            guard interface.ifa_addr.pointee.sa_family == UInt8(AF_INET),
                  String(cString: interface.ifa_name) != "lo0"
            else { continue }
            var host = [CChar](repeating: 0, count: Int(NI_MAXHOST))
            let length = socklen_t(interface.ifa_addr.pointee.sa_len)
            if getnameinfo(interface.ifa_addr, length, &host, socklen_t(host.count), nil, 0, NI_NUMERICHOST) == 0 {
                let bytes = host.prefix { $0 != 0 }.map { UInt8(bitPattern: $0) }
                if let address = String(bytes: bytes, encoding: .utf8) {
                    addresses.append(address)
                }
            }
        }
        return addresses
    }

    static func idleSeconds() -> TimeInterval {
        // kCGAnyInputEventType isn't exposed to Swift; it's ~0.
        guard let anyInput = CGEventType(rawValue: ~0) else { return 0 }
        return CGEventSource.secondsSinceLastEventType(.hidSystemState, eventType: anyInput)
    }
}
