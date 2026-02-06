//
//  GardenManager.swift
//  healinggarden2
//
//  Created by Naman Bhansali on 27/01/26.
//

import Foundation

class GardenManager {
    static let shared = GardenManager()
    
    private init() {
        // Mocking some initially unlocked items for testing
        unlockedItemIds.insert("1")
        unlockedItemIds.insert("2")
    }
    
    // User State
    var coins: Int = 32000
    var unlockedItemIds: Set<String> = []
    
    // FIXED: Added a computed property 'unlockedItems' so the ViewController can access it
    var unlockedItems: [StoreItem] {
        return storeCatalog.filter { unlockedItemIds.contains($0.id) }
    }
    
    // Store Data
    let storeCatalog: [StoreItem] = [
        StoreItem(id: "1", name: "Fountain", imageName: "fountain", price: 3000, category: "Wellness"),
        StoreItem(id: "2", name: "Bench", imageName: "bench", price: 2300, category: "Nature"),
        StoreItem(id: "3", name: "Hydrangea", imageName: "hydrangea", price: 3000, category: "Nature"),
        StoreItem(id: "4", name: "Tulips", imageName: "tulips", price: 2300, category: "Nature"),
        StoreItem(id: "5", name: "Bird Bath", imageName: "bird_bath", price: 1500, category: "Wellness")
    ]
    
    func getItems(for category: String) -> [StoreItem] {
        if category == "Your Items" {
            return unlockedItems
        }
        return storeCatalog.filter { $0.category == category }
    }
    
    func purchaseItem(_ item: StoreItem) -> Bool {
        if coins >= item.price && !unlockedItemIds.contains(item.id) {
            coins -= item.price
            unlockedItemIds.insert(item.id)
            return true
        }
        return false
    }
}
