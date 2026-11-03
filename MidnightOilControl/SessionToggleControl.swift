import AppIntents
import AppKit
import SwiftUI
import WidgetKit

@main
struct MidnightOilControls: WidgetBundle {
    var body: some Widget {
        SessionToggleControl()
    }
}

/// Starts or ends a session from Control Center, like the menu bar's flame.
struct SessionToggleControl: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: ControlBridge.controlKind, provider: Provider()) { isAwake in
            ControlWidgetToggle("Midnight Oil", isOn: isAwake, action: SetSessionIntent()) { isOn in
                Label(isOn ? "Keeping Awake" : "Off", systemImage: isOn ? "flame.fill" : "flame")
            }
        }
        .displayName("Keep Mac Awake")
        .description("Start or end a Midnight Oil session.")
    }

    struct Provider: ControlValueProvider {
        var previewValue: Bool { false }

        func currentValue() async throws -> Bool {
            // The app may have crashed mid-session; then nothing is keeping the Mac awake.
            let appIsRunning = !NSRunningApplication
                .runningApplications(withBundleIdentifier: ControlBridge.appBundleIdentifier).isEmpty
            return appIsRunning && ControlBridge.publishedIsAwake
        }
    }
}

struct SetSessionIntent: SetValueIntent {
    static let title: LocalizedStringResource = "Keep Mac Awake"

    @Parameter(title: "Keep awake")
    var value: Bool

    func perform() async throws -> some IntentResult {
        ControlBridge.request(awake: value)
        return .result()
    }
}
