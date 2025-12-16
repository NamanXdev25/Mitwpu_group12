import Foundation

// 1. Represents a single exercise row (Item)
struct DetailExerciseItem: Codable {
    let id: String         // NEW: stable identifier
    let title: String
    let subtitle: String
    let time: String
    let imageName: String
}

// 2. Represents a Section (e.g., "Low Energy")
struct DetailSectionData: Codable {
    let title: String
    let exercises: [DetailExerciseItem]
}

// 3. Overall structure: A dictionary mapping category names to arrays of sections
typealias ExerciseDatabase = [String: [DetailSectionData]]
