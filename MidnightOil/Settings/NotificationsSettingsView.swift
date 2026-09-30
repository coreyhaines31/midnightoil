import AppKit
import SwiftUI

struct NotificationsSettingsView: View {
    @AppStorage(Preferences.Key.notifiesOnSessionEnd) private var notifiesOnSessionEnd = true
    @AppStorage(Preferences.Key.notifiesOnTriggerStart) private var notifiesOnTriggerStart = false
    @AppStorage(Preferences.Key.notificationSound) private var notificationSound = Preferences.defaultSound
    @AppStorage(Preferences.Key.lidAlarmSound) private var lidAlarmSound = Preferences.defaultLidAlarmSound

    private let sounds = SystemSounds.names()

    var body: some View {
        Form {
            Section("Notify me when") {
                Toggle("A session ends on its own", isOn: $notifiesOnSessionEnd)
                Toggle("A trigger starts a session", isOn: $notifiesOnTriggerStart)
            }
            Section("Sounds") {
                LabeledContent("Notification sound") {
                    HStack {
                        Picker("", selection: $notificationSound) {
                            Text("Default").tag(Preferences.defaultSound)
                            Text("None").tag(Preferences.noSound)
                            Divider()
                            ForEach(sounds, id: \.self) { Text($0).tag($0) }
                        }
                        .labelsHidden()
                        Button("Play", systemImage: "play.fill") { SystemSounds.play(notificationSound) }
                            .labelStyle(.iconOnly)
                            .disabled(notificationSound == Preferences.noSound)
                    }
                }
                LabeledContent("Lid-close alarm") {
                    HStack {
                        Picker("", selection: $lidAlarmSound) {
                            ForEach(sounds, id: \.self) { Text($0).tag($0) }
                        }
                        .labelsHidden()
                        Button("Play", systemImage: "play.fill") { SystemSounds.play(lidAlarmSound) }
                            .labelStyle(.iconOnly)
                    }
                }
            }
        }
        .formStyle(.grouped)
    }
}

enum SystemSounds {
    private static let directory = URL(filePath: "/System/Library/Sounds")

    static func names() -> [String] {
        let files = (try? FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)) ?? []
        return files.map { $0.deletingPathExtension().lastPathComponent }.sorted()
    }

    static func fileName(_ name: String) -> String { "\(name).aiff" }

    static func play(_ name: String) {
        (NSSound(named: name) ?? NSSound(named: "Sosumi"))?.play()
    }
}
