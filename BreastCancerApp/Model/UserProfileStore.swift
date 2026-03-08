//
//  UserProfileStore.swift
//  BreastCancerApp
//

import UIKit

// Singleton shared store — any VC can read/write the same profile
class UserProfileStore {

    static let shared = UserProfileStore()
    private init() {}

    var profile = UserProfile.mock

    // Posted whenever the profile changes so all screens can refresh
    static let profileDidChangeNotification = Notification.Name("UserProfileDidChange")

    func save(_ updated: UserProfile) {
        profile = updated
        NotificationCenter.default.post(name: Self.profileDidChangeNotification, object: nil)
    }
}
