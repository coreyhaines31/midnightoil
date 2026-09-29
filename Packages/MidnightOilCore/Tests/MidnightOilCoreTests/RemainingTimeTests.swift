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

private let detailedCases: [(TimeInterval, String)] = [
    (45.9, "45s"),
    (620, "10m 20s"),
    (3_920, "1h 05m 20s"),
    (-5, "0s")
]

@Test(arguments: detailedCases)
func formatsDetailedCountdown(interval: TimeInterval, expected: String) {
    #expect(RemainingTime.detailed(interval) == expected)
}
