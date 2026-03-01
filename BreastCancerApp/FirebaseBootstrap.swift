//
//  FirebaseBootstrap.swift
//  BreastCancerApp
//
//  Created by Naman Bhansali on 01/03/26.
//

import Foundation
import FirebaseCore

enum FirebaseBootstrap {
    static func configureIfNeeded() {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
    }
}
