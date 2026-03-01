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
        for (dateKey, items) in appointments {
            let dtoItems = items.compactMap { FirestoreCodableBridge.toDictionary($0.toDTO()) }
            collection.document(dateKey).setData([
                "dateKey": dateKey,
                "items": dtoItems,
                "updatedAt": Timestamp(date: Date())
            ], merge: true)
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

            if !map.isEmpty {
                self.local.saveAppointments(map)
            }
        }
    }
}
