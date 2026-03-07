import Foundation

final class MemoryStore {
    static let shared = MemoryStore()

    private let repository: MemoryRepository

    init(repository: MemoryRepository = RepositoryFactory.makeMemoryRepository()) {
        self.repository = repository
    }

    func save(_ memories: [Memory]) {
        repository.saveMemories(memories)
    }

    func load() -> [Memory] {
        repository.loadMemories()
    }

    static func save(_ memories: [Memory]) {
        shared.save(memories)
    }

    static func load() -> [Memory] {
        shared.load()
    }
}
