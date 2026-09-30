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

    static func currentNetwork() -> String? {
        CWWiFiClient.shared().interface()?.ssid()
    }
}
