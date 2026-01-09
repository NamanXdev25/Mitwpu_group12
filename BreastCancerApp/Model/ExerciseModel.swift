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
        
        // Add dummy data for testing if no history exists
        addDummyDataForTesting()
        
        // Initialize history for all past dates on first load (but don't override dummy data)
        updateHistoryForAllDates()
    }
    
    // MARK: - Dummy Data for Testing
    func addDummyDataForTesting() {
        let calendar = Calendar.current
        let today = Date()
        
        // Add dummy data for the past 15 days
        for daysBack in 1...15 {
            if let pastDate = calendar.date(byAdding: .day, value: -daysBack, to: today) {
                let key = getDateKey(for: pastDate)
                
                // Skip if history already exists for this date
                if history[key] != nil {
                    print("⏭️ Skipping day \(daysBack) ago (\(key)) - data already exists")
                    continue
                }
                
                var dummyExercises: [PlanItem] = []
                
                // SPECIAL CASE 1: Day with NO exercises (8 days back)
                if daysBack == 8 {
                    // Don't add any exercises for this day
                    // This will show "No exercises planned"
                    print("⚠️ Day \(daysBack) ago (\(getDateKey(for: pastDate))): NO exercises")
                    continue
                }
                
                // SPECIAL CASE 2: Day with 10 MISSED exercises (5 days back = Jan 3)
                if daysBack == 5 {
                    print("🔥 Creating 10 exercises for day \(daysBack) ago (\(getDateKey(for: pastDate)))")
                    for i in 1...10 {
                        let hour = 7 + i
                        let timeString = hour < 12 ? "\(hour):00 AM" : (hour == 12 ? "12:00 PM" : "\(hour - 12):00 PM")
                        
                        dummyExercises.append(PlanItem(
                            id: "dummy_\(key)_\(i)",
                            title: "Exercise \(i)",
                            subtitle: "Every Day",
                            time: timeString,
                            isCompleted: false, // All missed
                            description: "Test exercise \(i)"
                        ))
                    }
                    history[key] = DailyProgress(items: dummyExercises)
                    print("✅ Added 10 MISSED exercises for \(getDateKey(for: pastDate))")
                    print("   Total: \(history[key]?.total ?? 0), Completed: \(history[key]?.completedCount ?? 0), Missed: \(history[key]?.missedItems.count ?? 0)")
                    saveHistory()
                    continue
                }
                
                // REGULAR DAYS: Normal dummy data
                // Exercise 1
                dummyExercises.append(PlanItem(
                    id: "dummy_\(key)_1",
                    title: "Morning Stretches",
                    subtitle: "Every Day",
                    time: "8:00 AM",
                    isCompleted: daysBack % 2 == 0, // Completed on even days
                    description: "Daily morning stretching routine"
                ))
                
                // Exercise 2
                dummyExercises.append(PlanItem(
                    id: "dummy_\(key)_2",
                    title: "Arm Exercises",
                    subtitle: "Every Day",
                    time: "2:00 PM",
                    isCompleted: daysBack % 3 == 0, // Completed every 3rd day
                    description: "Arm strengthening exercises"
                ))
                
                // Exercise 3 - add only to some days
                if daysBack <= 10 {
                    dummyExercises.append(PlanItem(
                        id: "dummy_\(key)_3",
                        title: "Evening Walk",
                        subtitle: "Every Day",
                        time: "6:00 PM",
                        isCompleted: false, // Not completed
                        description: "30 minute evening walk"
                    ))
                }
                
                // Exercise 4 - add for recent days
                if daysBack <= 7 {
                    dummyExercises.append(PlanItem(
                        id: "dummy_\(key)_4",
                        title: "Breathing Exercises",
                        subtitle: "Every Day",
                        time: "9:00 PM",
                        isCompleted: true,
                        description: "Deep breathing exercises"
                    ))
                }
                
                // Save to history
                history[key] = DailyProgress(items: dummyExercises)
                print("📝 Added \(dummyExercises.count) exercises for \(key)")
            }
        }
        
        saveHistory()
        
        // Calculate the date with 10 exercises for user reference
        if let testDate = calendar.date(byAdding: .day, value: -5, to: today) {
            let df = DateFormatter()
            df.dateFormat = "MMM d, yyyy"
            print("🎯 Check date \(df.string(from: testDate)) for 10 missed exercises")
        }
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
    
    func currentDayPlan(for date: Date) -> [PlanItem] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E"
        let dayMatch = "Every \(dateFormatter.string(from: date))"
        
        return todaysPlan.filter { item in
            return item.subtitle == "Every Day" || item.subtitle == dayMatch
        }
    }
    
    var currentDayPlan: [PlanItem] {
        return currentDayPlan(for: Date())
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
        let todayExercises = currentDayPlan
        if !todayExercises.isEmpty {
            history[key] = DailyProgress(items: todayExercises)
            saveHistory()
        }
    }
    
    // NEW: Update history for all past dates (but don't override dummy data)
    func updateHistoryForAllDates() {
        let calendar = Calendar.current
        let today = Date()
        
        // Get the earliest date we need to track
        let startDate = getAppStartDate()
        
        // Calculate number of days between start date and today
        let components = calendar.dateComponents([.day], from: startDate, to: today)
        guard let daysToCheck = components.day else { return }
        
        // Go through all days from start date to today
        for daysBack in 0...daysToCheck {
            if let pastDate = calendar.date(byAdding: .day, value: -daysBack, to: today) {
                let key = getDateKey(for: pastDate)
                
                // ✅ SKIP if dummy data already exists for this key
                if history[key] != nil {
                    continue  // Don't override dummy data
                }
                
                let exercisesForDate = currentDayPlan(for: pastDate)
                
                // Only add to history if there are exercises for this date
                if !exercisesForDate.isEmpty {
                    history[key] = DailyProgress(items: exercisesForDate)
                }
            }
        }
        saveHistory()
    }
    
    // Get the app start date (when user first installed/used the app)
    func getAppStartDate() -> Date {
        let startDateKey = "com.yourapp.startDate"
        
        // Check if we've already saved a start date
        if let savedTimestamp = UserDefaults.standard.object(forKey: startDateKey) as? TimeInterval {
            return Date(timeIntervalSince1970: savedTimestamp)
        } else {
            // First time - save current date as start date
            let now = Date()
            UserDefaults.standard.set(now.timeIntervalSince1970, forKey: startDateKey)
            return now
        }
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
