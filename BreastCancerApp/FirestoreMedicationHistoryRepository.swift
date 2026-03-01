//
//  FirestoreMedicationHistoryRepository.swift
//  BreastCancerApp
//
//  Created by Naman Bhansali on 01/03/26.
//

import Foundation
import FirebaseFirestore

final class FirestoreMedicationHistoryRepository: MedicationHistoryRepository {
    private let local: MedicationHistoryRepository
    private let userId: String

    init(
        local: MedicationHistoryRepository = UserDefaultsMedicationHistoryRepository(),
        userId: String = FirestoreUserContext.userId
    ) {
        self.local = local
        self.userId = userId
    }

    func loadHistory() -> [String: MedicationHistoryEntry] {
        let cached = local.loadHistory()
        syncFromCloudIntoLocal()
        return cached
    }

    func saveHistory(_ history: [String: MedicationHistoryEntry]) {
        local.saveHistory(history)

        let collection = FirestorePath.medicationHistory(userId)
        for (dateKey, entry) in history {
            guard let dto = FirestoreCodableBridge.toDictionary(entry.toDTO()) else { continue }
            collection.document(dateKey).setData(dto, merge: true)
        }
    }

    private func syncFromCloudIntoLocal() {
        let collection = FirestorePath.medicationHistory(userId)
        collection.getDocuments { [weak self] snapshot, _ in
            guard let self, let docs = snapshot?.documents else { return }

            var map: [String: MedicationHistoryEntry] = [:]
            for doc in docs {
                guard let dto = FirestoreCodableBridge.fromDictionary(doc.data(), as: MedicationHistoryEntryFirestoreDTO.self) else { continue }
                map[doc.documentID] = MedicationHistoryEntry(dto: dto)
            }

            if !map.isEmpty {
                self.local.saveHistory(map)
            }
        }
    }
}
