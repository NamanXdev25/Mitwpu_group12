//
//  GardenModel.swift
//  healinggarden2
//
//  Created by Naman Bhansali on 27/01/26.
//

import Foundation
import CoreGraphics

// The central data structure for all garden elements
struct StoreItem: Codable {
    let id: String
    let name: String
    let imageName: String
    let price: Int
    let category: String
}

// Data structure for items currently placed in the SKScene
struct PlacedItem: Codable {
    let id: String
    let imageName: String
    let positionX: CGFloat
    let positionY: CGFloat
    let zPosition: CGFloat
}
