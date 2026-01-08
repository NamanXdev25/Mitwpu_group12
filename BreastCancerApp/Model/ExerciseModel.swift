import UIKit

// --- 1. DATA STRUCTURES ---

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

// --- UPDATED: History Structure ---
// Now stores the actual items so we can see titles/times in the missed list
struct DailyProgress: Codable {
    let items: [PlanItem]
    
    var total: Int { items.count }
    var completedCount: Int { items.filter { $0.isCompleted }.count }
    var missedItems: [PlanItem] { items.filter { !$0.isCompleted } }
}

// --- 2. THE MANAGER ---

class ExerciseManager {
    
    static let shared = ExerciseManager()
    
    private let todaysPlanStorageKey = "com.yourapp.todaysPlan.v1"
    private let historyStorageKey = "com.yourapp.history.v1"
    
    var todaysPlan: [PlanItem] = []
    var myExercises: [ExerciseItem] = []
    var exploreItems: [ExerciseItem] = []
    
    // Key: "yyyy-MM-dd", Value: Progress object containing full items
    var history: [String: DailyProgress] = [:]
    
    init() {
        loadAllData()
        loadSavedPlan()
        loadHistory()
    }
    
    func loadAllData() {
        // Keeps your initial functionality for loading JSON assets
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
    
    // MARK: - Filter Logic
    
    var currentDayPlan: [PlanItem] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E"
        let todayMatch = "Every \(dateFormatter.string(from: Date()))"
        
        return todaysPlan.filter { item in
            return item.subtitle == "Every Day" || item.subtitle == todayMatch
        }
    }
    
    // MARK: - Plan manipulation
    
    func togglePlanItem(id: String) {
        if let index = todaysPlan.firstIndex(where: { $0.id == id }) {
            todaysPlan[index].isCompleted.toggle()
            saveTodaysPlan()
            updateHistoryForToday()
        }
    }
    
    func addPlanItem(_ item: PlanItem) {
        // Prevents duplicates by removing existing ID before inserting
        removeExercisesById(item.id)
        todaysPlan.insert(item, at: 0)
        saveTodaysPlan()
        updateHistoryForToday()
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
    
    // MARK: - Persistence
    
    func saveTodaysPlan() {
        do {
            let data = try JSONEncoder().encode(todaysPlan)
            UserDefaults.standard.set(data, forKey: todaysPlanStorageKey)
        } catch { print("Error saving plan: \(error)") }
    }
    
    func loadSavedPlan() {
        guard let data = UserDefaults.standard.data(forKey: todaysPlanStorageKey) else {
            // Fallback to local JSON if no User Defaults exist yet
            self.todaysPlan = loadJSON(filename: "todaysPlan")
            return
        }
        do {
            self.todaysPlan = try JSONDecoder().decode([PlanItem].self, from: data)
        } catch { print("Error loading plan: \(error)") }
    }
    
    // MARK: - History Logic
    
    func updateHistoryForToday() {
        let key = getTodayDateString()
        // Critical change: We save the full list of items instead of just counts
        history[key] = DailyProgress(items: currentDayPlan)
        saveHistory()
    }
    
    func saveHistory() {
        do {
            let data = try JSONEncoder().encode(history)
            UserDefaults.standard.set(data, forKey: historyStorageKey)
        } catch { print("Error saving history: \(error)") }
    }
    
    func loadHistory() {
        guard let data = UserDefaults.standard.data(forKey: historyStorageKey) else { return }
        do {
            self.history = try JSONDecoder().decode([String: DailyProgress].self, from: data)
        } catch { print("Error loading history: \(error)") }
    }
    
    // Helper to get consistent date keys
    func getTodayDateString() -> String {
        return getDateKey(for: Date())
    }
    
    func getDateKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
