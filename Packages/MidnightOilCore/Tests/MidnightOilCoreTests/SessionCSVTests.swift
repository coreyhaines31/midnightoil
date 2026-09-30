import Foundation
@testable import MidnightOilCore
import Testing

struct SessionCSVTests {
    @Test func writesAHeaderAndOneRowPerSession() {
        let start = Date(timeIntervalSince1970: 1_790_000_000)
        let record = SessionRecord(
            start: start,
            end: start.addingTimeInterval(3_600),
            endCause: .timeUp,
            subject: "Terminal",
            awakeTime: 3_600,
            awayTime: 1_800,
            batteryStart: 90,
            batteryEnd: 80
        )
        let lines = SessionCSV.make([record]).split(separator: "\n")
        #expect(lines.count == 2)
        #expect(lines[0].hasPrefix("start,end,awake_minutes"))
        #expect(lines[1].hasSuffix(",60,30,,timeUp,Terminal,,90,80"))
    }

    @Test func quotesFieldsWithCommas() {
        let start = Date(timeIntervalSince1970: 1_790_000_000)
        let record = SessionRecord(start: start, end: start, subject: "render, final.mov")
        #expect(SessionCSV.make([record]).contains("\"render, final.mov\""))
    }
}
