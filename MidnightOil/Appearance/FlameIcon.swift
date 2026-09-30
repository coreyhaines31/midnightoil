import AppKit

// The curve tables read best one segment per line.
// swiftlint:disable line_length

/// The Midnight Oil flame, drawn as vector paths so it stays crisp at any size.
/// Coordinates are fractions of the target rect, origin at the bottom left.
enum FlameIcon {
    private static func point(_ rect: NSRect, _ x: CGFloat, _ y: CGFloat) -> NSPoint {
        NSPoint(x: rect.minX + x * rect.width, y: rect.minY + y * rect.height)
    }

    /// The outer flame: a teardrop leaning right with a second lick on the left.
    static func outer(in rect: NSRect) -> NSBezierPath {
        let path = NSBezierPath()
        path.move(to: point(rect, 0.50, 0.00))
        path.curve(to: point(rect, 0.92, 0.36), controlPoint1: point(rect, 0.78, 0.00), controlPoint2: point(rect, 0.92, 0.16))
        path.curve(to: point(rect, 0.60, 0.98), controlPoint1: point(rect, 0.92, 0.62), controlPoint2: point(rect, 0.72, 0.78))
        path.curve(to: point(rect, 0.40, 0.62), controlPoint1: point(rect, 0.56, 0.84), controlPoint2: point(rect, 0.44, 0.74))
        path.curve(to: point(rect, 0.24, 0.80), controlPoint1: point(rect, 0.36, 0.70), controlPoint2: point(rect, 0.30, 0.78))
        path.curve(to: point(rect, 0.08, 0.36), controlPoint1: point(rect, 0.12, 0.72), controlPoint2: point(rect, 0.08, 0.54))
        path.curve(to: point(rect, 0.50, 0.00), controlPoint1: point(rect, 0.08, 0.16), controlPoint2: point(rect, 0.22, 0.00))
        path.close()
        return path
    }

    /// The inner flame near the base.
    static func inner(in rect: NSRect) -> NSBezierPath {
        let path = NSBezierPath()
        path.move(to: point(rect, 0.50, 0.10))
        path.curve(to: point(rect, 0.70, 0.32), controlPoint1: point(rect, 0.64, 0.10), controlPoint2: point(rect, 0.70, 0.20))
        path.curve(to: point(rect, 0.50, 0.56), controlPoint1: point(rect, 0.70, 0.46), controlPoint2: point(rect, 0.58, 0.52))
        path.curve(to: point(rect, 0.30, 0.32), controlPoint1: point(rect, 0.40, 0.50), controlPoint2: point(rect, 0.30, 0.44))
        path.curve(to: point(rect, 0.50, 0.10), controlPoint1: point(rect, 0.30, 0.20), controlPoint2: point(rect, 0.36, 0.10))
        path.close()
        return path
    }

    /// Filled flame with the inner flame cut out.
    static func filled(in rect: NSRect) -> NSBezierPath {
        let path = outer(in: rect)
        path.append(inner(in: rect))
        path.windingRule = .evenOdd
        return path
    }

    static func draw(in rect: NSRect, lit: Bool) {
        if lit {
            filled(in: rect).fill()
        } else {
            let outline = outer(in: rect)
            outline.lineWidth = rect.width * 0.11
            outline.lineJoinStyle = .round
            outline.stroke()
            let core = inner(in: rect)
            core.lineWidth = rect.width * 0.10
            core.stroke()
        }
    }

    /// Menu bar template image: outline when idle, filled while awake.
    static func menuBarImage(lit: Bool, size: CGFloat = 18) -> NSImage {
        let image = NSImage(size: NSSize(width: size, height: size), flipped: false) { _ in
            NSColor.black.set()
            // The flame is taller than wide; keep it centered with a hairline of breathing room.
            let width = size * 0.74, height = size * 0.92
            draw(in: NSRect(x: (size - width) / 2, y: (size - height) / 2, width: width, height: height), lit: lit)
            return true
        }
        image.isTemplate = true
        return image
    }
}

// swiftlint:enable line_length
