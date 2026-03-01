//
//  FirestoreSupport.swift
//  BreastCancerApp
//
//  Created by Naman Bhansali on 01/03/26.
//

import Foundation
import FirebaseFirestore

enum FirestoreUserContext {
    private static let key = "firestore_user_id"

    static var userId: String {
        if let existing = UserDefaults.standard.string(forKey: key), !existing.isEmpty {
            return existing
        }
        let generated = UUID().uuidString
        UserDefaults.standard.set(generated, forKey: key)
        return generated
    }
}

enum FirestorePath {
    static func appointments(_ userId: String) -> CollectionReference {
        Firestore.firestore().collection("users").document(userId).collection("appointments")
    }

    static func medicationHistory(_ userId: String) -> CollectionReference {
        Firestore.firestore().collection("users").document(userId).collection("medicationHistory")
    }

    static func memories(_ userId: String) -> CollectionReference {
        Firestore.firestore().collection("users").document(userId).collection("memories")
    }

    static func hydration(_ userId: String) -> CollectionReference {
        Firestore.firestore().collection("users").document(userId).collection("hydration")
    }
    
    static func symptoms(_ userId: String) -> CollectionReference {
        Firestore.firestore().collection("users").document(userId).collection("symptoms")
    }
    
    static func journals(_ userId: String) -> CollectionReference {
        Firestore.firestore().collection("users").document(userId).collection("journals")
    }

    static func breathing(_ userId: String) -> CollectionReference {
        Firestore.firestore().collection("users").document(userId).collection("breathing")
    }


}

enum FirestoreCodableBridge {
    static func toDictionary<T: Encodable>(_ value: T) -> [String: Any]? {
        guard let data = try? JSONEncoder().encode(value),
              let object = try? JSONSerialization.jsonObject(with: data),
              let dict = object as? [String: Any] else {
            return nil
        }
        return dict
    }

    static func fromDictionary<T: Decodable>(_ dictionary: [String: Any], as type: T.Type) -> T? {
        guard JSONSerialization.isValidJSONObject(dictionary),
              let data = try? JSONSerialization.data(withJSONObject: dictionary) else {
            return nil
        }
        return try? JSONDecoder().decode(T.self, from: data)
    }
}
