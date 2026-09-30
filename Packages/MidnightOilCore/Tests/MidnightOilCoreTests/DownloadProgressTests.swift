import Foundation
@testable import MidnightOilCore
import Testing

struct DownloadProgressTests {
    let start = Date(timeIntervalSinceReferenceDate: 1_000_000)

    /// Feeds (seconds since start, size) samples and returns whether each one
    /// still counted as downloading.
    func run(_ file: String, stallTimeout: TimeInterval = 60, samples: [(TimeInterval, Int64?)]) -> [Bool] {
        var progress = DownloadProgress(file: URL(filePath: file), startedAt: start, stallTimeout: stallTimeout)
        return samples.map { progress.update(size: $0.1, at: start.addingTimeInterval($0.0)) }
    }

    @Test(arguments: ["movie.mov.download", "setup.dmg.crdownload", "file.zip.part", "x.PART"])
    func recognizesBrowserPartialFiles(name: String) {
        #expect(DownloadProgress(file: URL(filePath: "/tmp/\(name)"), startedAt: start).isPartialFile)
    }

    @Test func partialFileIsDownloadingUntilItDisappears() {
        let results = run("/tmp/a.crdownload", samples: [(500, 10), (5_000, 10), (5_001, nil)])
        #expect(results == [true, true, false])
    }

    @Test func regularFileIsDownloadingWhileItGrows() {
        let results = run("/tmp/a.iso", samples: [(0, 100), (50, 200), (100, 300), (159, 300), (160, 300)])
        #expect(results == [true, true, true, true, false])
    }

    @Test func regularFileThatNeverGrowsFinishesAfterTheTimeout() {
        #expect(run("/tmp/done.iso", samples: [(1, 500), (61, 500)]) == [true, false])
    }

    @Test func missingRegularFileIsFinished() {
        #expect(run("/tmp/gone.iso", samples: [(1, nil)]) == [false])
    }

    @Test func displayNameDropsTheBrowserSuffix() {
        #expect(DownloadProgress.displayName(for: URL(filePath: "/tmp/setup.dmg.crdownload")) == "setup.dmg")
        #expect(DownloadProgress.displayName(for: URL(filePath: "/tmp/setup.dmg")) == "setup.dmg")
    }
}
