import Foundation

class HomeDataStore {
    static let shared = HomeDataStore()
    
    private var goals: [HomeTodaysGoalModel] = []
    private var upcomingEvents: [HomeUpcomingModel] = []
    private var memories: [HomeMemoryModel] = []
    private var articles: [ArticleModel] = []
    
    var userProfile: UserProfile?
    var gardenStats: HealingGardenStats = HealingGardenStats(
        currentPoints: 4200,
        totalPointsNeeded: 5000,
        currentLevel: 1,
        nextLevel: 2
    )
    
    private init() {
        loadDataFromJSON()
    }
    
    private func loadDataFromJSON() {
        goals = loadJSON("Goals.json")
        upcomingEvents = loadJSON("Upcoming.json")
        memories = loadJSON("Memories.json")
        let response: ArticlesResponse = loadJSON("articles.json")
        articles = response.articles
    }
    
    private func loadJSON<T: Decodable>(_ filename: String) -> T {
        guard let url = Bundle.main.url(forResource: filename, withExtension: nil) else {
            fatalError("Failed to locate \(filename) in bundle.")
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            fatalError("Failed to decode \(filename) from bundle: \(error)")
        }
    }
    
    func getGoals() -> [HomeTodaysGoalModel] {
        return goals
    }
    
    func getUpcomingEvents() -> [HomeUpcomingModel] {
        return upcomingEvents
    }
    
    func getMemories() -> [HomeMemoryModel] {
        return memories
    }
    
    func getArticles() -> [ArticleModel] {
        return articles
    }
    
    
    func getCompletedGoals() -> [HomeTodaysGoalModel] {
        return goals.filter { $0.isCompleted }
    }
    
    func getIncompleteGoals() -> [HomeTodaysGoalModel] {
        return goals.filter { !$0.isCompleted }
    }
    
    func getTotalPointsEarned() -> Int {
        return goals.filter { $0.isCompleted }
            .compactMap { Int($0.points.filter { $0.isNumber }) }
            .reduce(0, +)
    }

    func toggleGoalCompletion(at index: Int) {
        guard index < goals.count else { return }
        goals[index] = HomeTodaysGoalModel(
            title: goals[index].title,
            points: goals[index].points,
            iconName: goals[index].iconName,
            isCompleted: !goals[index].isCompleted
        )
    }
    
    func addMemory(_ memory: HomeMemoryModel) {
        memories.insert(memory, at: 0)
    }
    
    func addUpcomingEvent(_ event: HomeUpcomingModel) {
        upcomingEvents.append(event)
    }
    
    
    func addPoints(_ points: Int) {
        gardenStats.currentPoints += points
        
        // level up logic
        if gardenStats.currentPoints >= gardenStats.totalPointsNeeded {
            levelUp()
        }
    }
    
    private func levelUp() {
        gardenStats.currentLevel += 1
        gardenStats.nextLevel = gardenStats.currentLevel + 1
        gardenStats.currentPoints = gardenStats.currentPoints - gardenStats.totalPointsNeeded
        gardenStats.totalPointsNeeded = Int(Double(gardenStats.totalPointsNeeded) * 1.5) // Increase difficulty
    }
}
