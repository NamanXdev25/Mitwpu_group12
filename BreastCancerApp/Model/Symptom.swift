//
//  Symptom.swift
//  symptomTracking
//
//  Created by Shivani Dinesh on 04/01/26.
//

import Foundation

struct Symptom: Codable {
    let id: String
    let name: String
    let description: String
    var isInUserList: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case isInUserList = "isInUserListByDefault"
    }
}

struct SymptomsData: Codable {
    let symptoms: [Symptom]
}
