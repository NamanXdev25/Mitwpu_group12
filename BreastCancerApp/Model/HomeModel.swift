import Foundation

struct HomeTodaysGoalModel: Codable {
    let title: String
    let points: String
    let iconName: String
    let isCompleted: Bool
}

struct HomeUpcomingModel: Codable {
    let title: String
    let doctorName: String
    let date: String
    let time: String
}

struct HomeMemoryModel: Codable {
    let imageName: String
    let date: String
    let description: String
}
