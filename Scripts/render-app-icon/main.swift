// Renders the app icon set from LampIcon's paths.
// Usage (from the repo root):
//   swiftc Scripts/render-app-icon/main.swift MidnightOil/Appearance/LampIcon.swift -o /tmp/render-icon && /tmp/render-icon
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
    let lampRect = plate.insetBy(dx: plate.width * 0.16, dy: plate.height * 0.18)
    let glowCenter = NSPoint(x: lampRect.minX + lampRect.width * 0.20, y: lampRect.minY + lampRect.height * 0.62)
    let glow = NSGradient(colors: [
        NSColor(red: 1.0, green: 0.72, blue: 0.30, alpha: 0.55),
        NSColor(red: 1.0, green: 0.72, blue: 0.30, alpha: 0.0)
    ])!
    plateShape.addClip()
    glow.draw(fromCenter: glowCenter, radius: 0, toCenter: glowCenter, radius: plate.width * 0.42, options: [])

    NSColor(red: 0.96, green: 0.76, blue: 0.28, alpha: 1).setFill()
    LampIcon.body(in: lampRect).fill()
    LampIcon.base(in: lampRect).fill()
    LampIcon.handle(in: lampRect).fill()

    let flame = LampIcon.flame(in: lampRect)
    let flameGradient = NSGradient(colors: [
        NSColor(red: 1.0, green: 0.55, blue: 0.15, alpha: 1),
        NSColor(red: 1.0, green: 0.88, blue: 0.45, alpha: 1)
    ])!
    flameGradient.draw(in: flame, angle: 90)

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
