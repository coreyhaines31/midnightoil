import AppKit

/// The menu bar image for each state: built-in symbols, or the user's own images.
enum StatusIcon {
    enum Style: String, CaseIterable {
        case flame
        case custom
    }

    enum State: String {
        case inactive
        case active
    }

    private static let barHeight: CGFloat = 18

    static func image(for state: State) -> NSImage? {
        if Preferences.statusIconStyle == .custom, let custom = customImage(for: state) {
            return custom
        }
        let symbol = state == .active ? "flame.fill" : "flame"
        let image = NSImage(systemSymbolName: symbol, accessibilityDescription: nil)
        image?.isTemplate = true
        return image
    }

    static func customImageURL(for state: State) -> URL {
        let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        return support.appending(path: "Midnight Oil/icon-\(state.rawValue).png")
    }

    static func customImage(for state: State) -> NSImage? {
        guard let image = NSImage(contentsOf: customImageURL(for: state)) else { return nil }
        let scale = barHeight / max(image.size.height, 1)
        image.size = NSSize(width: image.size.width * scale, height: barHeight)
        image.isTemplate = Preferences.customIconsAreTemplates
        return image
    }

    /// Copies a chosen image into Application Support as PNG.
    static func setCustomImage(_ source: URL, for state: State) throws {
        guard let image = NSImage(contentsOf: source),
              let tiff = image.tiffRepresentation,
              let png = NSBitmapImageRep(data: tiff)?.representation(using: .png, properties: [:])
        else { throw CocoaError(.fileReadCorruptFile) }
        let destination = customImageURL(for: state)
        try FileManager.default.createDirectory(
            at: destination.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try png.write(to: destination, options: .atomic)
    }

    static func clearCustomImage(for state: State) {
        try? FileManager.default.removeItem(at: customImageURL(for: state))
    }
}
