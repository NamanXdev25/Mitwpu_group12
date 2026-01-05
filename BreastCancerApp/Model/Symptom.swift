//
//  Symptom.swift
//  symptomTracking
//
//  Created by Shivani Dinesh on 04/01/26.
//

import Foundation

struct Symptom {
    let id: String
    let name: String
    var isInUserList: Bool
    
    init(id: String, name: String, isInUserList: Bool = false) {
        self.id = id
        self.name = name
        self.isInUserList = isInUserList
    }
}
