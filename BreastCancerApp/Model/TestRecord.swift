import Foundation

struct ObservationItem: Codable {
    let title: String
    let value: String
}

struct TestRecord: Codable {
    let id: UUID
    let date: Date
    let observations: [ObservationItem]
}

enum Persistence {
    static let key = "com.yourapp.testRecords"
    static func save(_ records: [TestRecord]) throws {
        let data = try JSONEncoder().encode(records)
        UserDefaults.standard.set(data, forKey: key)
    }
    static func load() -> [TestRecord] {
        guard let d = UserDefaults.standard.data(forKey: key) else { return [] }
        return (try? JSONDecoder().decode([TestRecord].self, from: d)) ?? []
    }
}
