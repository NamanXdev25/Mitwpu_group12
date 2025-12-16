import UIKit

struct PlanItem: Codable {
    var id: String
    var title: String
    var subtitle: String
    var time: String
    var isCompleted: Bool
    var description: String?
}

struct ExerciseItem: Codable {
    var title: String
    var category: String
    var imageName: String
}

struct DailyProgress: Codable {
    let total: Int
    let completed: Int
}

class ExerciseManager {
    
    static let shared = ExerciseManager()
    
    private let todaysPlanStorageKey = "com.yourapp.todaysPlan.v1"
    private let historyStorageKey = "com.yourapp.history.v1"
    
    var todaysPlan: [PlanItem] = []
    var myExercises: [ExerciseItem] = []
    var exploreItems: [ExerciseItem] = []
    
    var history: [String: DailyProgress] = [:]
    
    init() {
        loadAllData()
        loadSavedPlan()
        loadHistory()
    }
    
    func loadAllData() {
        self.todaysPlan = loadJSON(filename: "todaysPlan")
        self.myExercises = loadJSON(filename: "myExercises")
        self.exploreItems = loadJSON(filename: "explore")
    }
    
    func loadJSON<T: Codable>(filename: String) -> [T] {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else { return [] }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([T].self, from: data)
        } catch {
            print("Error parsing \(filename).json: \(error)")
            return []
        }
    }
    
    var currentDayPlan: [PlanItem] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E"
        let todayShort = dateFormatter.string(from: Date())
        let todayMatch = "Every \(todayShort)"
        
        return todaysPlan.filter { item in
            item.subtitle == "Every Day" || item.subtitle == todayMatch
        }
    }
    
    func togglePlanItem(id: String) {
        if let index = todaysPlan.firstIndex(where: { $0.id == id }) {
            todaysPlan[index].isCompleted.toggle()
            saveTodaysPlan()
            updateHistoryForToday()
        }
    }
    
    func addPlanItem(_ item: PlanItem) {
        if containsExercise(id: item.id) {
            _ = removeExercisesById(item.id)
        }
        todaysPlan.insert(item, at: 0)
        saveTodaysPlan()
        updateHistoryForToday()
    }

    func containsExercise(title: String) -> Bool {
        return todaysPlan.contains { $0.title == title }
    }

    func containsExercise(id: String) -> Bool {
        return todaysPlan.contains { $0.id == id }
    }

    @discardableResult
    func removeExercisesById(_ id: String) -> Int {
        let before = todaysPlan.count
        todaysPlan.removeAll { $0.id == id }
        let removed = before - todaysPlan.count
        if removed > 0 {
            saveTodaysPlan()
            updateHistoryForToday()
        }
        return removed
    }
    
    func saveTodaysPlan() {
        do {
            let data = try JSONEncoder().encode(todaysPlan)
            UserDefaults.standard.set(data, forKey: todaysPlanStorageKey)
        } catch {
            print("Error saving plan: \(error)")
        }
    }
    
    func loadSavedPlan() {
        guard let data = UserDefaults.standard.data(forKey: todaysPlanStorageKey) else { return }
        do {
            self.todaysPlan = try JSONDecoder().decode([PlanItem].self, from: data)
        } catch {
            print("Error loading plan: \(error)")
        }
    }
    
    func updateHistoryForToday() {
        let key = getTodayDateString()
        let dailyPlan = self.currentDayPlan
        let total = dailyPlan.count
        let completed = dailyPlan.filter { $0.isCompleted }.count
        let progress = DailyProgress(total: total, completed: completed)
        history[key] = progress
        saveHistory()
    }
    
    func saveHistory() {
        do {
            let data = try JSONEncoder().encode(history)
            UserDefaults.standard.set(data, forKey: historyStorageKey)
        } catch {
            print("Error saving history: \(error)")
        }
    }
    
    func loadHistory() {
        guard let data = UserDefaults.standard.data(forKey: historyStorageKey) else { return }
        do {
            self.history = try JSONDecoder().decode([String: DailyProgress].self, from: data)
        } catch {
            print("Error loading history: \(error)")
        }
    }
    
    func getTodayDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}
