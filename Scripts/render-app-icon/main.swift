// Renders the app icon set from FlameIcon's paths.
// Usage (from the repo root):
//   swiftc Scripts/render-app-icon/main.swift MidnightOil/Appearance/FlameIcon.swift -o /tmp/render-icon && /tmp/render-icon
import AppKit

let outputDirectory = URL(filePath: "MidnightOil/Assets.xcassets/AppIcon.appiconset")

func render(_ pixels: Int) -> Data {
    let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil, pixelsWide: pixels, pixelsHigh: pixels, bitsPerSample: 8, samplesPerPixel: 4,
        hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0
    )!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    let size = CGFloat(pixels)
    let canvas = NSRect(x: 0, y: 0, width: size, height: size)

    // macOS icon grid: the rounded square fills 824/1024 of the canvas.
    let plate = canvas.insetBy(dx: size * 100 / 1024, dy: size * 100 / 1024)
    let plateShape = NSBezierPath(roundedRect: plate, xRadius: plate.width * 0.2237, yRadius: plate.height * 0.2237)
    let midnight = NSGradient(colors: [
        NSColor(red: 0.20, green: 0.22, blue: 0.42, alpha: 1),
        NSColor(red: 0.07, green: 0.08, blue: 0.18, alpha: 1)
    ])!
    midnight.draw(in: plateShape, angle: -90)

    // Warm glow behind the flame.
    let flameRect = NSRect(
        x: plate.minX + plate.width * 0.25, y: plate.minY + plate.height * 0.16,
        width: plate.width * 0.50, height: plate.height * 0.66
    )
    let glowCenter = NSPoint(x: flameRect.midX, y: flameRect.minY + flameRect.height * 0.45)
    let glow = NSGradient(colors: [
        NSColor(red: 1.0, green: 0.62, blue: 0.25, alpha: 0.55),
        NSColor(red: 1.0, green: 0.62, blue: 0.25, alpha: 0.0)
    ])!
    plateShape.addClip()
    glow.draw(fromCenter: glowCenter, radius: 0, toCenter: glowCenter, radius: plate.width * 0.46, options: [])

    // The flame: orange at the base rising to gold, inner flame cut out so the glow shows through.
    let flameGradient = NSGradient(colors: [
        NSColor(red: 1.0, green: 0.50, blue: 0.16, alpha: 1),
        NSColor(red: 0.98, green: 0.80, blue: 0.32, alpha: 1)
    ])!
    flameGradient.draw(in: FlameIcon.filled(in: flameRect), angle: 90)

    NSGraphicsContext.restoreGraphicsState()
    return rep.representation(using: .png, properties: [:])!
}

let sizes: [(points: Int, scale: Int)] = [
    (16, 1), (16, 2), (32, 1), (32, 2), (128, 1), (128, 2), (256, 1), (256, 2), (512, 1), (512, 2)
]
var images: [[String: String]] = []
for entry in sizes {
    let name = "icon_\(entry.points)x\(entry.points)@\(entry.scale)x.png"
    try! render(entry.points * entry.scale).write(to: outputDirectory.appending(path: name))
    images.append(["filename": name, "idiom": "mac", "scale": "\(entry.scale)x", "size": "\(entry.points)x\(entry.points)"])
}
let contents: [String: Any] = ["images": images, "info": ["author": "xcode", "version": 1]]
let json = try! JSONSerialization.data(withJSONObject: contents, options: [.prettyPrinted, .sortedKeys])
try! json.write(to: outputDirectory.appending(path: "Contents.json"))
print("Wrote \(images.count) icons to \(outputDirectory.path)")
