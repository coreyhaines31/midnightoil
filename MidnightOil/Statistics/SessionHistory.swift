import Foundation
import MidnightOilCore
import Observation
import os

/// Finished sessions, kept as JSON in Application Support (most recent 1,000).
@MainActor
@Observable
final class SessionHistory {
    private static let limit = 1_000
    private static let logger = Logger(subsystem: "app.midnightoil.MidnightOil", category: "History")
    private static var fileURL: URL {
        let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        return support.appending(path: "Midnight Oil/sessions.json")
    }

    private(set) var records: [SessionRecord]

    init() {
        records = Self.load()
    }

    func record(_ record: SessionRecord) {
        records.append(record)
        if records.count > Self.limit { records.removeFirst(records.count - Self.limit) }
        save()
    }

    func clear() {
        records = []
        save()
    }

    private static func load() -> [SessionRecord] {
        guard let data = try? Data(contentsOf: fileURL) else { return [] }
        do {
            // Skip any single record we can't read rather than losing them all.
            return try JSONDecoder().decode([LossyRecord].self, from: data).compactMap(\.record)
        } catch {
            logger.error("Couldn't read session history: \(error.localizedDescription, privacy: .public)")
            // Keep the unreadable file instead of overwriting it on the next save.
            let backup = fileURL.deletingPathExtension().appendingPathExtension("unreadable.json")
            try? FileManager.default.removeItem(at: backup)
            try? FileManager.default.moveItem(at: fileURL, to: backup)
            return []
        }
    }

    private func save() {
        do {
            let url = Self.fileURL
            let directory = url.deletingLastPathComponent()
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            try JSONEncoder().encode(records).write(to: url, options: .atomic)
        } catch {
            Self.logger.error("Couldn't save session history: \(error.localizedDescription, privacy: .public)")
        }
    }
}

/// Decodes one history entry, or nothing if that entry is malformed.
private struct LossyRecord: Decodable {
    let record: SessionRecord?

    init(from decoder: Decoder) throws {
        record = try? SessionRecord(from: decoder)
    }
}
