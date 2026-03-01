//
//  FirestoreSymptomRepository.swift
//  BreastCancerApp
//
//  Created by Naman Bhansali on 01/03/26.
//

import Foundation
import FirebaseFirestore

final class FirestoreSymptomRepository: SymptomRepository {
    private let local: SymptomRepository
    private let userId: String
    private let stateDocId = "state"

    init(
        local: SymptomRepository = UserDefaultsSymptomRepository(),
        userId: String = FirestoreUserContext.userId
    ) {
        self.local = local
        self.userId = userId
    }

    func loadLogs() -> [SymptomLog] {
        let cached = local.loadLogs()
        syncFromCloudIntoLocal()
        return cached
    }

    func saveLogs(_ logs: [SymptomLog]) {
        local.saveLogs(logs)
        uploadCurrentState()
    }

    func loadUserSymptomIDs() -> [String] {
        let cached = local.loadUserSymptomIDs()
        syncFromCloudIntoLocal()
        return cached
    }

    func saveUserSymptomIDs(_ ids: [String]) {
        local.saveUserSymptomIDs(ids)
        uploadCurrentState()
    }

    private func uploadCurrentState() {
        let collection = FirestorePath.symptoms(userId)
        let logsDTO = local.loadLogs().compactMap { FirestoreCodableBridge.toDictionary($0.toDTO()) }
        let ids = local.loadUserSymptomIDs()

        collection.document(stateDocId).setData([
            "logs": logsDTO,
            "userSymptomIds": ids,
            "updatedAt": Timestamp(date: Date())
        ], merge: true)
    }

    private func syncFromCloudIntoLocal() {
        let collection = FirestorePath.symptoms(userId)
        collection.document(stateDocId).getDocument { [weak self] snapshot, _ in
            guard let self, let data = snapshot?.data() else { return }

            let rawLogs = data["logs"] as? [[String: Any]] ?? []
            let logs: [SymptomLog] = rawLogs.compactMap {
                guard let dto = FirestoreCodableBridge.fromDictionary($0, as: SymptomLogFirestoreDTO.self) else { return nil }
                return SymptomLog(dto: dto)
            }

            let ids = data["userSymptomIds"] as? [String] ?? []

            self.local.saveLogs(logs.sorted { $0.timestamp > $1.timestamp })
            self.local.saveUserSymptomIDs(ids)
        }
    }
}
