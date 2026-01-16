import Foundation

struct DetailExerciseItem: Codable {
    let id: String
    let title: String
    let subtitle: String
    let time: String
    let imageName: String
}

struct DetailSectionData: Codable {
    let title: String
    let exercises: [DetailExerciseItem]
}

typealias ExerciseDatabase = [String: [DetailSectionData]]
