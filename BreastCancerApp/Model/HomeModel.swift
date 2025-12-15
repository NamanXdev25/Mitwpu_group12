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


struct HomeArticleModel: Codable {
    let title: String
    let subtitle: String
    let imageName: String
}

struct HealingGardenStats {
    var currentPoints: Int
    var totalPointsNeeded: Int
    var currentLevel: Int
    var nextLevel: Int
    
    var progress: Float {
        return Float(currentPoints) / Float(totalPointsNeeded)
    }
    
    var pointsToNextLevel: Int {
        return totalPointsNeeded - currentPoints
    }
}

struct UserProfile {
    var name: String
    var profileImageName: String?
    var joinDate: Date
    
    init(name: String, profileImageName: String? = nil, joinDate: Date = Date()) {
        self.name = name
        self.profileImageName = profileImageName
        self.joinDate = joinDate
    }
}
