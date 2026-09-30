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

    func record(_ session: Session, endedAt end: Date) {
        var triggerName: String?
        if case .trigger(_, let name) = session.source { triggerName = name }
        records.append(SessionRecord(start: session.start, end: end, triggerName: triggerName))
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
            return try JSONDecoder().decode([SessionRecord].self, from: data)
        } catch {
            logger.error("Couldn't read session history: \(error.localizedDescription, privacy: .public)")
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
