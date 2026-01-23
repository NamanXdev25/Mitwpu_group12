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
        // Remove the upcomingEvents loading from JSON since we'll get it from AppointmentManager
        // upcomingEvents = loadJSON("Upcoming.json")
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
    
    // MARK: - Get Nearest Upcoming Appointment (Real-time from AppointmentManager)
    func getUpcomingAppointment() -> HomeUpcomingModel? {
        let calendar = Calendar.current
        let now = Date()
        
        // Get all appointments from AppointmentManager
        let allDates = AppointmentManager.shared.getAllDatesWithAppointments()
        
        var nearestAppointment: AppointmentItem?
        var nearestDate: Date?
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        timeFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        // Loop through all dates
        for dateString in allDates {
            guard let date = dateFormatter.date(from: dateString) else { continue }
            
            // Get appointments for this date
            let appointments = AppointmentManager.shared.getAppointments(for: date)
            
            for appointment in appointments {
                // Parse the appointment time
                guard let time = timeFormatter.date(from: appointment.time) else { continue }
                
                // Combine date and time
                let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
                let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
                
                var fullComponents = dateComponents
                fullComponents.hour = timeComponents.hour
                fullComponents.minute = timeComponents.minute
                
                guard let fullDate = calendar.date(from: fullComponents) else { continue }
                
                // Only consider future appointments
                if fullDate > now {
                    if nearestDate == nil || fullDate < nearestDate! {
                        nearestDate = fullDate
                        nearestAppointment = appointment
                    }
                }
            }
        }
        
        // Convert to HomeUpcomingModel if found
        if let appointment = nearestAppointment {
            // Use note as doctorName, or show category if note is empty
            let displayText = !appointment.note.isEmpty ? appointment.note : appointment.category
            
            return HomeUpcomingModel(
                title: appointment.title,
                doctorName: displayText,
                date: appointment.date,
                time: appointment.time
            )
        }
        
        return nil
    }
    
    func getUpcomingEvents() -> [HomeUpcomingModel] {
        // Return as array for compatibility with existing code
        if let appointment = getUpcomingAppointment() {
            return [appointment]
        }
        return []
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
