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
            PaneIntro(intro: Help.Pane.notifications)
            ManagedNotice(keys: [
                Preferences.Key.notifiesOnSessionEnd,
                Preferences.Key.notifiesOnTriggerStart,
                Preferences.Key.notificationSound,
                Preferences.Key.lidAlarmSound
            ])

            Section("Notify me when") {
                Toggle(isOn: $notifiesOnSessionEnd) { InfoLabel("A session ends on its own", info: Help.notifyEnd) }
                    .help(Help.notifyEnd)
                    .managed(Preferences.Key.notifiesOnSessionEnd)
                Toggle(isOn: $notifiesOnTriggerStart) {
                    InfoLabel("A schedule or trigger starts a session", info: Help.notifyTriggerStart)
                }
                .help(Help.notifyTriggerStart)
                .managed(Preferences.Key.notifiesOnTriggerStart)
            }
            Section("Sounds") {
                LabeledContent {
                    HStack {
                        Picker("", selection: $notificationSound) {
                            Text("Default").tag(Preferences.defaultSound)
                            Text("None").tag(Preferences.noSound)
                            Divider()
                            ForEach(sounds, id: \.self) { Text($0).tag($0) }
                        }
                        .labelsHidden()
                        .managed(Preferences.Key.notificationSound)
                        Button("Play", systemImage: "play.fill") { SystemSounds.play(notificationSound) }
                            .labelStyle(.iconOnly)
                            .help(Help.playSound)
                            .disabled(notificationSound == Preferences.noSound)
                    }
                } label: {
                    InfoLabel("Notification sound", info: Help.notificationSound)
                }
                LabeledContent {
                    HStack {
                        Picker("", selection: $lidAlarmSound) {
                            ForEach(sounds, id: \.self) { Text($0).tag($0) }
                        }
                        .labelsHidden()
                        .managed(Preferences.Key.lidAlarmSound)
                        Button("Play", systemImage: "play.fill") { SystemSounds.play(lidAlarmSound) }
                            .labelStyle(.iconOnly)
                            .help(Help.playSound)
                    }
                } label: {
                    InfoLabel("Lid-close alarm", info: Help.lidAlarmSound)
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
