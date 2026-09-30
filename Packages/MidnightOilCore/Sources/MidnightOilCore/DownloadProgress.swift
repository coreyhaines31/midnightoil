import Foundation

/// Decides whether a watched file is still downloading.
///
/// Browsers download into a temporary file (Safari `.download`, Chrome
/// `.crdownload`, Firefox `.part`) and rename it when done, so for those the
/// download is finished once that file is gone. Any other file counts as
/// downloading while it keeps growing, and as finished once its size has held
/// still for `stallTimeout`.
public struct DownloadProgress: Sendable {
    public static let partialExtensions: Set<String> = ["download", "crdownload", "part", "partial", "opdownload"]
    public static let defaultStallTimeout: TimeInterval = 60

    public let isPartialFile: Bool
    public let stallTimeout: TimeInterval
    private var lastSize: Int64?
    private var lastChange: Date

    public init(file: URL, startedAt now: Date, stallTimeout: TimeInterval = defaultStallTimeout) {
        isPartialFile = Self.partialExtensions.contains(file.pathExtension.lowercased())
        self.stallTimeout = stallTimeout
        lastChange = now
    }

    /// Feed the file's current size (nil if it no longer exists). Returns
    /// whether the download is still in progress.
    public mutating func update(size: Int64?, at now: Date) -> Bool {
        guard let size else { return false }
        if isPartialFile { return true }

        if size != lastSize {
            lastSize = size
            lastChange = now
        }
        return now.timeIntervalSince(lastChange) < stallTimeout
    }
}
