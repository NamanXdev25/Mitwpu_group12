//
//  FirestoreMemoryRepository.swift
//  BreastCancerApp
//
//  Created by Naman Bhansali on 01/03/26.
//

import Foundation
import FirebaseFirestore

final class FirestoreMemoryRepository: MemoryRepository {
    private let local: MemoryRepository
    private let userId: String

    init(
        local: MemoryRepository = UserDefaultsMemoryRepository(),
        userId: String = FirestoreUserContext.userId
    ) {
        self.local = local
        self.userId = userId
    }

    func loadMemories() -> [Memory] {
        let cached = local.loadMemories()
        syncFromCloudIntoLocal()
        return cached
    }

    func saveMemories(_ memories: [Memory]) {
        local.saveMemories(memories)

        let collection = FirestorePath.memories(userId)
        let batch = Firestore.firestore().batch()

        for memory in memories {
            guard let dto = FirestoreCodableBridge.toDictionary(memory.toDTO()) else { continue }
            let ref = collection.document(memory.id)
            batch.setData(dto, forDocument: ref, merge: true)
        }

        batch.commit()
    }

    private func syncFromCloudIntoLocal() {
        let collection = FirestorePath.memories(userId)
        collection.getDocuments { [weak self] snapshot, _ in
            guard let self, let docs = snapshot?.documents else { return }

            let models: [Memory] = docs.compactMap {
                guard let dto = FirestoreCodableBridge.fromDictionary($0.data(), as: MemoryFirestoreDTO.self) else { return nil }
                return Memory(dto: dto)
            }

            if !models.isEmpty {
                self.local.saveMemories(models.sorted(by: { $0.date > $1.date }))
            }
        }
    }
}
