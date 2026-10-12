import AppKit
import CoreLocation
import CoreWLAN

/// macOS 14+ only reveals the Wi-Fi network name to apps with Location access,
/// so the first Wi-Fi criterion asks for it.
@MainActor
enum WifiAccess {
    private static var manager: CLLocationManager?

    static func requestIfNeeded() {
        guard manager == nil else { return }
        let manager = CLLocationManager()
        self.manager = manager
        if manager.authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        }
    }

    /// True once someone has said no to Location, so the network name can't be read and
    /// macOS won't ask again. Only System Settings can change it from here.
    static var isDenied: Bool {
        let status = (manager ?? CLLocationManager()).authorizationStatus
        return status == .denied || status == .restricted
    }

    static func openLocationSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_LocationServices") {
            NSWorkspace.shared.open(url)
        }
    }

    static func currentNetwork() -> String? {
        CWWiFiClient.shared().interface()?.ssid()
    }
}
