//
//  FirestoreJournalRepository.swift
//  BreastCancerApp
//
//  Created by Naman Bhansali on 02/03/26.
//

import Foundation
import FirebaseFirestore

final class FirestoreJournalRepository: JournalRepository {
    private let local: JournalRepository
    private let userId: String
    private let stateDocId = "state"

    init(
        local: JournalRepository = UserDefaultsJournalRepository(),
        userId: String = FirestoreUserContext.userId
    ) {
        self.local = local
        self.userId = userId
    }

    func loadEntries() -> [JournalEntry] {
        let cached = local.loadEntries()
        syncFromCloudIntoLocal()
        return cached
    }

    func saveEntries(_ entries: [JournalEntry]) {
        local.saveEntries(entries)

        let raw = entries.compactMap { FirestoreCodableBridge.toDictionary($0.toDTO()) }
        FirestorePath.journals(userId).document(stateDocId).setData([
            "entries": raw,
            "updatedAt": Timestamp(date: Date())
        ], merge: true)
    }

    private func syncFromCloudIntoLocal() {
        FirestorePath.journals(userId).document(stateDocId).getDocument { [weak self] snapshot, _ in
            guard let self, let data = snapshot?.data() else { return }

            let rawEntries = data["entries"] as? [[String: Any]] ?? []
            let entries: [JournalEntry] = rawEntries.compactMap {
                guard let dto = FirestoreCodableBridge.fromDictionary($0, as: JournalEntryFirestoreDTO.self) else { return nil }
                return JournalEntry(dto: dto)
            }

            if !entries.isEmpty {
                self.local.saveEntries(entries)
            }
        }
    }
}
