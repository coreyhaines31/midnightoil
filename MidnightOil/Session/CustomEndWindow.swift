import AppKit
import SwiftUI

/// The "Other Time…" window: pick any future date and time to stay awake until.
@MainActor
final class CustomEndWindow {
    private var window: NSWindow?

    func show(onStart: @escaping (Date) -> Void) {
        let view = CustomEndView(
            onStart: { [weak self] date in
                onStart(date)
                self?.close()
            },
            onCancel: { [weak self] in self?.close() }
        )
        let window = self.window ?? NSWindow()
        window.contentViewController = NSHostingController(rootView: view)
        window.title = "Keep Awake Until"
        window.styleMask = [.titled, .closable]
        window.isReleasedWhenClosed = false
        window.center()
        self.window = window

        NSApp.activate()
        window.makeKeyAndOrderFront(nil)
    }

    private func close() {
        window?.close()
    }
}

private struct CustomEndView: View {
    @State private var endDate = Date.now.addingTimeInterval(3_600)
    let onStart: (Date) -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            DatePicker(
                "Keep awake until",
                selection: $endDate,
                in: Date.now...,
                displayedComponents: [.date, .hourAndMinute]
            )
            HStack {
                Spacer()
                Button("Cancel", action: onCancel)
                    .keyboardShortcut(.cancelAction)
                Button("Start") { onStart(endDate) }
                    .keyboardShortcut(.defaultAction)
                    .disabled(endDate <= .now)
            }
        }
        .padding(20)
        .frame(width: 360)
    }
}
