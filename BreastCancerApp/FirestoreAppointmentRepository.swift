//
//  FirestoreAppointmentRepository.swift
//  BreastCancerApp
//
//  Created by Naman Bhansali on 01/03/26.
//

import Foundation
import FirebaseFirestore

final class FirestoreAppointmentRepository: AppointmentRepository {
    private let local: AppointmentRepository
    private let userId: String

    init(
        local: AppointmentRepository = UserDefaultsAppointmentRepository(),
        userId: String = FirestoreUserContext.userId
    ) {
        self.local = local
        self.userId = userId
    }

    func loadAppointments() -> [String: [AppointmentItem]] {
        let cached = local.loadAppointments()
        syncFromCloudIntoLocal()
        return cached
    }

    func saveAppointments(_ appointments: [String: [AppointmentItem]]) {
        local.saveAppointments(appointments)

        let collection = FirestorePath.appointments(userId)
        collection.getDocuments { snapshot, _ in
            guard let snapshot else {
                self.writeAppointmentsToCloud(appointments, in: collection)
                return
            }

            let batch = collection.firestore.batch()
            let existingKeys = Set(snapshot.documents.map(\.documentID))
            let currentKeys = Set(appointments.keys)

            for removedKey in existingKeys.subtracting(currentKeys) {
                batch.deleteDocument(collection.document(removedKey))
            }

            for (dateKey, items) in appointments {
                let dtoItems = items.compactMap { FirestoreCodableBridge.toDictionary($0.toDTO()) }
                batch.setData([
                    "dateKey": dateKey,
                    "items": dtoItems,
                    "updatedAt": Timestamp(date: Date())
                ], forDocument: collection.document(dateKey))
            }

            batch.commit()
        }
    }

    private func syncFromCloudIntoLocal() {
        let collection = FirestorePath.appointments(userId)
        collection.getDocuments { [weak self] snapshot, _ in
            guard let self, let docs = snapshot?.documents else { return }

            var map: [String: [AppointmentItem]] = [:]
            for doc in docs {
                let dateKey = doc.documentID
                let rawItems = doc.data()["items"] as? [[String: Any]] ?? []
                let models: [AppointmentItem] = rawItems.compactMap {
                    guard let dto = FirestoreCodableBridge.fromDictionary($0, as: AppointmentFirestoreDTO.self) else { return nil }
                    return AppointmentItem(dto: dto)
                }
                map[dateKey] = models
            }

            self.local.saveAppointments(map)
        }
    }

    private func writeAppointmentsToCloud(
        _ appointments: [String: [AppointmentItem]],
        in collection: CollectionReference
    ) {
        for (dateKey, items) in appointments {
            let dtoItems = items.compactMap { FirestoreCodableBridge.toDictionary($0.toDTO()) }
            collection.document(dateKey).setData([
                "dateKey": dateKey,
                "items": dtoItems,
                "updatedAt": Timestamp(date: Date())
            ])
        }
    }
}
