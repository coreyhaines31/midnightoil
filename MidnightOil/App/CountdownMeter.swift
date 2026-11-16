import MidnightOilCore
import PanelKit
import SwiftUI

/// The countdown for sessions with a length: the scale runs from 0 to the session's length, the needle
/// starts at the right stop and sweeps down to 0, and a printed band shows the time still to run.
struct CountdownMeter: View {
    var total: TimeInterval
    var remaining: TimeInterval
    var accessibilityValue: String

    var body: some View {
        let scale = CountdownScale(total: total)
        let needle = CountdownScale.needle(remaining: remaining, total: total)
        Meter(
            MeterConfig(
                majorTicks: scale.divisions,
                minorTicks: max(2, 20 / scale.divisions),
                bands: needle > 0 ? [MeterBand(0...needle, width: 3, opacity: 0.9)] : [],
                labels: scale.labels.map { MeterLabel($0.position, $0.text) },
                word: scale.word,
                face: .lit,
                accessibilityLabel: "Countdown meter"
            ),
            value: needle,
            accessibilityValue: accessibilityValue
        )
    }
}
