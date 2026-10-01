import Foundation
import MidnightOilCore
import Observation
import os

/// The user's schedules, persisted as JSON in UserDefaults.
@MainActor
@Observable
final class ScheduleStore {
    private static let key = "schedules"
    private static let logger = Logger(subsystem: "app.midnightoil.MidnightOil", category: "Schedules")

    var schedules: [AwakeSchedule] {
        didSet {
            save()
            onChange?()
        }
    }

    @ObservationIgnored var onChange: (() -> Void)?

    init() {
        schedules = Self.load()
    }

    private static func load() -> [AwakeSchedule] {
        guard let data = UserDefaults.standard.data(forKey: key) else { return [] }
        do {
            return try JSONDecoder().decode([AwakeSchedule].self, from: data)
        } catch {
            logger.error("Couldn't read saved schedules: \(error.localizedDescription, privacy: .public)")
            return []
        }
    }

    private func save() {
        do {
            UserDefaults.standard.set(try JSONEncoder().encode(schedules), forKey: Self.key)
        } catch {
            Self.logger.error("Couldn't save schedules: \(error.localizedDescription, privacy: .public)")
        }
    }
}
