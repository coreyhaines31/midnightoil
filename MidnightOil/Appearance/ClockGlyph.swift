import AppKit

/// The 24-hour clock menu bar glyph, drawn from the same geometry as mac-app-kit's
/// `Scripts/glyphs/glyphs.mjs` (18 pt grid, SVG coordinates with y down).
/// Idle: the dial in outline with the hand. Awake: the night half filled, the hand cut out of it.
enum ClockGlyph {
    private static let center = NSPoint(x: 9, y: 9)
    private static let handAngle = 334.5

    static func image(awake: Bool) -> NSImage {
        let image = NSImage(size: NSSize(width: 18, height: 18), flipped: true) { _ in
            NSColor.black.set()
            draw(awake: awake)
            return true
        }
        image.isTemplate = true
        return image
    }

    private static func draw(awake: Bool) {
        let ring = NSBezierPath(ovalIn: NSRect(x: 9 - 7.6, y: 9 - 7.6, width: 15.2, height: 15.2))
        ring.lineWidth = 1.5
        ring.stroke()

        // Hour ticks at 6, 12 and 18; idle also shows 24 at the top, which the filled night half covers.
        for degrees in awake ? [90.0, 180, 270] : [0.0, 90, 180, 270] {
            stroke(from: point(5.6, degrees), to: point(6.6, degrees), width: 1.1)
        }

        if awake {
            let night = NSBezierPath()
            night.move(to: NSPoint(x: 1.4, y: 9))
            night.appendArc(withCenter: center, radius: 7.6, startAngle: 180, endAngle: 0, clockwise: false)
            night.close()
            night.append(capsule(from: point(1.6, handAngle), to: point(5.4, handAngle), width: 1.4))
            night.windingRule = .evenOdd
            night.fill()
        } else {
            stroke(from: center, to: point(5.4, handAngle), width: 1.4)
        }

        NSBezierPath(ovalIn: NSRect(x: 9 - 1.1, y: 9 - 1.1, width: 2.2, height: 2.2)).fill()
    }

    /// A point at `radius` from the centre at a dial angle in degrees (0 = straight up).
    private static func point(_ radius: CGFloat, _ degrees: Double) -> NSPoint {
        let radians = (degrees - 90) * .pi / 180
        return NSPoint(x: center.x + radius * cos(radians), y: center.y + radius * sin(radians))
    }

    private static func stroke(from start: NSPoint, to end: NSPoint, width: CGFloat) {
        let line = NSBezierPath()
        line.move(to: start)
        line.line(to: end)
        line.lineWidth = width
        line.lineCapStyle = .round
        line.stroke()
    }

    /// A round-capped line as a closed outline, so it can be cut out of a fill.
    private static func capsule(from start: NSPoint, to end: NSPoint, width: CGFloat) -> NSBezierPath {
        let deltaX = end.x - start.x
        let deltaY = end.y - start.y
        let length = (deltaX * deltaX + deltaY * deltaY).squareRoot()
        let shape = NSBezierPath(
            roundedRect: NSRect(x: 0, y: -width / 2, width: length, height: width),
            xRadius: width / 2,
            yRadius: width / 2
        )
        var transform = AffineTransform(translationByX: start.x, byY: start.y)
        transform.rotate(byRadians: atan2(deltaY, deltaX))
        shape.transform(using: transform)
        return shape
    }
}
