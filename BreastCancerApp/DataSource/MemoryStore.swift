import Foundation

final class MemoryStore {

    private static let key = "saved_memories"

    static func save(_ memories: [Memory]) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        if let data = try? encoder.encode(memories) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    static func load() -> [Memory] {
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return []
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        return (try? decoder.decode([Memory].self, from: data)) ?? []
    }
}
