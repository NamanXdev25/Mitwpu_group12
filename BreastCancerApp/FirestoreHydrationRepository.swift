//
//  FirestoreHydrationRepository.swift
//  BreastCancerApp
//
//  Created by Naman Bhansali on 01/03/26.
//

import Foundation
import FirebaseFirestore

final class FirestoreHydrationRepository: HydrationRepository {
    private let local: HydrationRepository
    private let userId: String

    init(
        local: HydrationRepository = UserDefaultsHydrationRepository(),
        userId: String = FirestoreUserContext.userId
    ) {
        self.local = local
        self.userId = userId
    }

    func loadEntries() -> [HydrationEntry] {
        let cached = local.loadEntries()
        syncFromCloudIntoLocal()
        return cached
    }

    func saveEntries(_ entries: [HydrationEntry]) {
        local.saveEntries(entries)

        let collection = FirestorePath.hydration(userId)
        let batch = Firestore.firestore().batch()

        for entry in entries {
            guard let dto = FirestoreCodableBridge.toDictionary(entry.toDTO()) else { continue }
            let ref = collection.document(entry.id.uuidString)
            batch.setData(dto, forDocument: ref, merge: true)
        }

        batch.commit()
    }

    private func syncFromCloudIntoLocal() {
        let collection = FirestorePath.hydration(userId)
        collection.getDocuments { [weak self] snapshot, _ in
            guard let self, let docs = snapshot?.documents else { return }

            let models: [HydrationEntry] = docs.compactMap {
                guard let dto = FirestoreCodableBridge.fromDictionary($0.data(), as: HydrationEntryFirestoreDTO.self) else { return nil }
                return HydrationEntry(dto: dto)
            }

            if !models.isEmpty {
                self.local.saveEntries(models.sorted(by: { $0.timestamp > $1.timestamp }))
            }
        }
    }
}
