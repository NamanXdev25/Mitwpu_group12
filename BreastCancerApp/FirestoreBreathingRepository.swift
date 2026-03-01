//
//  FirestoreBreathingRepository.swift
//  BreastCancerApp
//
//  Created by Naman Bhansali on 02/03/26.
//

import Foundation
import FirebaseFirestore

final class FirestoreBreathingRepository: BreathingRepository {
    private let local: BreathingRepository
    private let userId: String
    private let stateDocId = "favorites"

    init(
        local: BreathingRepository = UserDefaultsBreathingRepository(),
        userId: String = FirestoreUserContext.userId
    ) {
        self.local = local
        self.userId = userId
    }

    func loadFavoriteTitles() -> Set<String> {
        let cached = local.loadFavoriteTitles()
        syncFromCloudIntoLocal()
        return cached
    }

    func saveFavoriteTitles(_ titles: Set<String>) {
        local.saveFavoriteTitles(titles)

        FirestorePath.breathing(userId).document(stateDocId).setData([
            "favoriteTitles": Array(titles),
            "updatedAt": Timestamp(date: Date())
        ], merge: true)
    }

    private func syncFromCloudIntoLocal() {
        FirestorePath.breathing(userId).document(stateDocId).getDocument { [weak self] snapshot, _ in
            guard let self, let data = snapshot?.data() else { return }
            let titles = Set(data["favoriteTitles"] as? [String] ?? [])
            self.local.saveFavoriteTitles(titles)
        }
    }
}
