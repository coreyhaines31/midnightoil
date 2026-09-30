import Foundation
import MidnightOilCore
import Observation
import os

/// The user's triggers, persisted as JSON in UserDefaults.
@MainActor
@Observable
final class TriggerStore {
    private static let key = "triggers"
    private static let logger = Logger(subsystem: "app.midnightoil.MidnightOil", category: "Triggers")

    var triggers: [Trigger] {
        didSet { save() }
    }

    init() {
        triggers = Self.load()
    }

    private static func load() -> [Trigger] {
        guard let data = UserDefaults.standard.data(forKey: key) else { return [] }
        do {
            return try JSONDecoder().decode([Trigger].self, from: data)
        } catch {
            logger.error("Couldn't read saved triggers: \(error.localizedDescription, privacy: .public)")
            return []
        }
    }

    private func save() {
        do {
            UserDefaults.standard.set(try JSONEncoder().encode(triggers), forKey: Self.key)
        } catch {
            Self.logger.error("Couldn't save triggers: \(error.localizedDescription, privacy: .public)")
        }
    }
}
