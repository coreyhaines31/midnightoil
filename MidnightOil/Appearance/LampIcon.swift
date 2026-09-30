import AppKit

// The curve tables read best one segment per line.
// swiftlint:disable line_length

/// The Midnight Oil lamp, drawn as vector paths so it stays crisp at any size.
/// Coordinates are fractions of the target rect, origin at the bottom left.
/// The lamp sits slightly right of center to leave room for the flame.
enum LampIcon {
    private static func point(_ rect: NSRect, _ x: CGFloat, _ y: CGFloat) -> NSPoint {
        NSPoint(x: rect.minX + (0.12 + x * 0.88) * rect.width, y: rect.minY + y * rect.height)
    }

    private static func square(_ rect: NSRect, _ x: CGFloat, _ y: CGFloat, _ size: CGFloat) -> NSRect {
        let origin = point(rect, x, y)
        return NSRect(x: origin.x, y: origin.y, width: size * 0.88 * rect.width, height: size * 0.88 * rect.height)
    }

    static func body(in rect: NSRect) -> NSBezierPath {
        let path = NSBezierPath()
        path.move(to: point(rect, 0.00, 0.50))
        path.curve(to: point(rect, 0.28, 0.62), controlPoint1: point(rect, 0.10, 0.58), controlPoint2: point(rect, 0.18, 0.62))
        path.curve(to: point(rect, 0.64, 0.60), controlPoint1: point(rect, 0.40, 0.66), controlPoint2: point(rect, 0.54, 0.66))
        path.curve(to: point(rect, 0.76, 0.46), controlPoint1: point(rect, 0.72, 0.56), controlPoint2: point(rect, 0.76, 0.52))
        path.curve(to: point(rect, 0.52, 0.20), controlPoint1: point(rect, 0.76, 0.32), controlPoint2: point(rect, 0.68, 0.20))
        path.curve(to: point(rect, 0.18, 0.26), controlPoint1: point(rect, 0.38, 0.20), controlPoint2: point(rect, 0.26, 0.20))
        path.curve(to: point(rect, 0.00, 0.50), controlPoint1: point(rect, 0.10, 0.32), controlPoint2: point(rect, 0.02, 0.42))
        path.close()
        return path
    }

    static func base(in rect: NSRect) -> NSBezierPath {
        let path = NSBezierPath()
        let stem = point(rect, 0.31, 0.14)
        path.appendRect(NSRect(x: stem.x, y: stem.y, width: 0.12 * 0.88 * rect.width, height: 0.12 * rect.height))
        let foot = point(rect, 0.20, 0.06)
        path.append(NSBezierPath(ovalIn: NSRect(
            x: foot.x, y: foot.y, width: 0.34 * 0.88 * rect.width, height: 0.13 * rect.height
        )))
        return path
    }

    /// The handle: a ring, so fill it with its even-odd rule.
    static func handle(in rect: NSRect) -> NSBezierPath {
        let path = NSBezierPath()
        path.appendOval(in: square(rect, 0.68, 0.31, 0.28))
        path.appendOval(in: square(rect, 0.75, 0.38, 0.14))
        path.windingRule = .evenOdd
        return path
    }

    static func flame(in rect: NSRect) -> NSBezierPath {
        let path = NSBezierPath()
        path.move(to: point(rect, 0.01, 0.52))
        path.curve(to: point(rect, 0.10, 0.96), controlPoint1: point(rect, -0.12, 0.70), controlPoint2: point(rect, -0.04, 0.90))
        path.curve(to: point(rect, 0.01, 0.52), controlPoint1: point(rect, 0.26, 0.86), controlPoint2: point(rect, 0.24, 0.64))
        path.close()
        return path
    }

    static func draw(in rect: NSRect, lit: Bool) {
        body(in: rect).fill()
        base(in: rect).fill()
        handle(in: rect).fill()
        if lit { flame(in: rect).fill() }
    }

    /// Menu bar template image: lamp only, or lamp with flame while awake.
    static func menuBarImage(lit: Bool, size: CGFloat = 18) -> NSImage {
        let image = NSImage(size: NSSize(width: size, height: size), flipped: false) { rect in
            NSColor.black.setFill()
            draw(in: rect.insetBy(dx: 0.5, dy: 0.5), lit: lit)
            return true
        }
        image.isTemplate = true
        return image
    }
}

// swiftlint:enable line_length
