import MidnightOilCore
import PanelKit
import SwiftUI

/// The tape transport for sessions with no end to show: two chrome reels and an elapsed counter
/// behind the same chrome bezel as the meters. The reels turn and the face is lit while a session
/// runs; idle, the face is cream and the reels stand still. Reduce Motion stops the reels too.
struct ReelGauge: View {
    var elapsed: TimeInterval
    var isRunning: Bool
    var caption: String
    var accessibilityValue: String

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Design size, the same as the single `Meter`, so every instrument fills the fascia alike.
    static let size = CGSize(width: 312, height: 104)
    /// Seconds per turn of the reels: slow enough to read as calm, quick enough to see.
    static let secondsPerTurn: TimeInterval = 6

    var body: some View {
        let digits = ElapsedCounter.digits(elapsed)
        let spins = isRunning && !reduceMotion
        // The animation timeline only exists while the menu is open (the menu rebuilds its card each
        // time) and is paused when the reels stand still, so a closed menu costs nothing.
        TimelineView(.animation(minimumInterval: 1.0 / 20, paused: !spins)) { context in
            ReelFace(turn: spins ? Self.turn(at: context.date) : 0, isLit: isRunning, caption: caption)
        }
        .overlay {
            GeometryReader { proxy in
                let scale = proxy.size.width / Self.size.width
                ZStack {
                    DrumDigits(digits.hours)
                        .position(x: 125, y: 40)
                    DrumDigits(digits.minutes)
                        .position(x: 187, y: 40)
                }
                .frame(width: Self.size.width, height: Self.size.height)
                .scaleEffect(scale, anchor: .topLeading)
            }
        }
        .aspectRatio(Self.size.width / Self.size.height, contentMode: .fit)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Tape counter")
        .accessibilityValue(accessibilityValue)
    }

    /// How far the reels have turned at a moment, in degrees.
    static func turn(at date: Date) -> Double {
        date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: secondsPerTurn) / secondsPerTurn * 360
    }
}

/// Bezel, face, reels, tape path, the counter's colon and the caption, in 312 x 104 design units.
private struct ReelFace: View {
    var turn: Double
    var isLit: Bool
    var caption: String

    private static let reels = [CGPoint(x: 60, y: 48), CGPoint(x: 252, y: 48)]

    var body: some View {
        Canvas(rendersAsynchronously: false) { context, size in
            let scale = size.width / ReelGauge.size.width
            context.scaleBy(x: scale, y: scale)
            let ink = isLit ? Color(reelHex: 0x2A2216) : Color(reelHex: 0x1D1D1D)
            drawBezelAndFace(&context)
            var face = context
            face.clip(to: Path(roundedRect: Self.faceRect, cornerRadius: 4))
            drawTape(&face, ink: ink)
            for center in Self.reels {
                drawReel(&face, center: center, ink: ink)
            }
            drawCounterParts(&face, ink: ink)
            // Glass highlight across the top of the window, as on the meters.
            face.fill(
                Path(CGRect(x: 3, y: 3, width: 306, height: 14)),
                with: .color(.white.opacity(isLit ? 0.05 : 0.18))
            )
            context.fill(circle(CGPoint(x: 11, y: 11), 3), with: .color(Color(reelHex: 0x1B1B1B).opacity(0.75)))
        }
        .allowsHitTesting(false)
    }

    private static let faceRect = CGRect(x: 3, y: 3, width: 306, height: 98)

    private func drawBezelAndFace(_ context: inout GraphicsContext) {
        let bezelRect = CGRect(x: 1.5, y: 1.5, width: 309, height: 101)
        context.fill(
            Path(roundedRect: bezelRect, cornerRadius: 5.5),
            with: .linearGradient(
                Self.chrome,
                startPoint: bezelRect.origin,
                endPoint: CGPoint(x: bezelRect.maxX, y: bezelRect.maxY)
            )
        )
        let rect = Self.faceRect
        // PanelKit's meter faces: lit amber while running, cream when off.
        let stops: [Gradient.Stop] = isLit
            ? [.init(color: Color(reelHex: 0xE4B768), location: 0),
               .init(color: Color(reelHex: 0xF6DFAA), location: 0.75)]
            : [.init(color: Color(reelHex: 0xE2DDCF), location: 0),
               .init(color: Color(reelHex: 0xF4F2EB), location: 0.7)]
        var face = context
        face.clip(to: Path(roundedRect: rect, cornerRadius: 4))
        face.translateBy(x: rect.midX, y: rect.minY + rect.height * 1.1)
        face.scaleBy(x: 1, y: rect.height / rect.width)
        face.fill(
            Path(CGRect(x: -rect.width * 2, y: -rect.width * 2, width: rect.width * 4, height: rect.width * 4)),
            with: .radialGradient(Gradient(stops: stops), center: .zero, startRadius: 0, endRadius: rect.width)
        )
    }

    /// The tape leaves the bottom of one pack, runs past two guides and the head, and onto the other.
    private func drawTape(_ context: inout GraphicsContext, ink: Color) {
        var tape = Path()
        tape.move(to: CGPoint(x: 60, y: 76))
        tape.addLine(to: CGPoint(x: 98, y: 91))
        tape.addLine(to: CGPoint(x: 214, y: 91))
        tape.addLine(to: CGPoint(x: 252, y: 76))
        context.stroke(tape, with: .color(ink.opacity(0.8)), lineWidth: 1.6)
        for x in [98.0, 214] {
            let guide = circle(CGPoint(x: x, y: 91), 3)
            context.fill(guide, with: .linearGradient(
                Self.chrome, startPoint: CGPoint(x: x - 3, y: 88), endPoint: CGPoint(x: x + 3, y: 94)
            ))
            context.stroke(guide, with: .color(ink.opacity(0.5)), lineWidth: 0.6)
        }
        let head = Path(roundedRect: CGRect(x: 143, y: 89, width: 26, height: 9), cornerRadius: 1.5)
        context.fill(
            head,
            with: .linearGradient(Self.chrome, startPoint: CGPoint(x: 143, y: 89), endPoint: CGPoint(x: 169, y: 98))
        )
        context.stroke(head, with: .color(ink.opacity(0.55)), lineWidth: 0.7)
    }

    /// A chrome reel with three windows onto the tape pack, turned by `turn` degrees.
    private func drawReel(_ context: inout GraphicsContext, center: CGPoint, ink: Color) {
        let flange: CGFloat = 32
        context.fill(circle(center, 28), with: .color(ink.opacity(0.85)))

        var plate = circle(center, flange)
        for index in 0..<3 {
            let mid = turn + Double(index) * 120
            var window = Path()
            // Dial degrees (0 = up) to SwiftUI's (0 = right); `clockwise: false` turns clockwise on screen.
            let angle = mid - 90
            window.addArc(
                center: center,
                radius: 27,
                startAngle: .degrees(angle - 34),
                endAngle: .degrees(angle + 34),
                clockwise: false
            )
            window.addArc(
                center: center,
                radius: 12,
                startAngle: .degrees(angle + 28),
                endAngle: .degrees(angle - 28),
                clockwise: true
            )
            window.closeSubpath()
            plate.addPath(window)
        }
        context.fill(
            plate,
            with: .linearGradient(
                Self.chrome,
                startPoint: CGPoint(x: center.x - flange, y: center.y - flange),
                endPoint: CGPoint(x: center.x + flange, y: center.y + flange)
            ),
            style: FillStyle(eoFill: true)
        )
        context.stroke(circle(center, flange), with: .color(ink.opacity(0.55)), lineWidth: 0.8)

        // Hub: a dark spindle ring with three drive teeth.
        context.fill(circle(center, 7), with: .color(ink.opacity(0.9)))
        context.fill(circle(center, 4.2), with: .color(Color(reelHex: 0xD9DADB)))
        for index in 0..<3 {
            let angle = (turn + Double(index) * 120 + 60 - 90) * .pi / 180
            let tip = CGPoint(x: center.x + 6.6 * cos(angle), y: center.y + 6.6 * sin(angle))
            context.fill(circle(tip, 1.3), with: .color(Color(reelHex: 0xD9DADB)))
        }
    }

    /// The colon between the hours and minutes drums, and the caption under them.
    private func drawCounterParts(_ context: inout GraphicsContext, ink: Color) {
        context.fill(circle(CGPoint(x: 156, y: 35), 1.6), with: .color(ink.opacity(0.85)))
        context.fill(circle(CGPoint(x: 156, y: 45), 1.6), with: .color(ink.opacity(0.85)))
        let text = context.resolve(
            Text(caption).font(PanelFont.condensed(10, .medium)).tracking(2.5).foregroundStyle(ink.opacity(0.8))
        )
        let measured = text.measure(in: CGSize(width: 200, height: 40))
        context.draw(text, in: CGRect(origin: CGPoint(x: 156 - measured.width / 2, y: 64), size: measured))
    }

    private func circle(_ center: CGPoint, _ radius: CGFloat) -> Path {
        Path(ellipseIn: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2))
    }

    /// PanelKit's meter-bezel chrome.
    private static let chrome = Gradient(stops: [
        .init(color: Color(reelHex: 0xFBFBFB), location: 0),
        .init(color: Color(reelHex: 0x8C8E90), location: 0.35),
        .init(color: Color(reelHex: 0xEEEFF0), location: 0.55),
        .init(color: Color(reelHex: 0x6E7072), location: 0.8),
        .init(color: Color(reelHex: 0xD9DADB), location: 1)
    ])
}

private extension Color {
    /// PanelKit's palette values, which it keeps internal.
    init(reelHex hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}
