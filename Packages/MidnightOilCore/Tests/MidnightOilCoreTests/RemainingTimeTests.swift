import Foundation
@testable import MidnightOilCore
import Testing

private let cases: [(TimeInterval, String)] = [
    (30, "<1m"),
    (60, "1m"),
    (61, "2m"),
    (1_500, "25m"),
    (3_600, "1h"),
    (3_900, "1h 05m"),
    (28_799, "8h")
]

@Test(arguments: cases)
func formatsCompactCountdown(interval: TimeInterval, expected: String) {
    #expect(RemainingTime.short(interval) == expected)
}
