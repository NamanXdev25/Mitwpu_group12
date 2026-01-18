import UIKit

struct PlanItem: Codable {
    var id: String
    var title: String
    var subtitle: String
    var time: String
    var isCompleted: Bool
    var description: String?
    var hasReminder: Bool?
}

struct ExerciseItem: Codable {
    var title: String
    var category: String
    var imageName: String
}

struct DailyProgress: Codable {
    let items: [PlanItem]
    
    var total: Int { items.count }
    var completedCount: Int { items.filter { $0.isCompleted }.count }
    var missedItems: [PlanItem] { items.filter { !$0.isCompleted } }
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
        
        addDummyDataForTesting()
        
        updateHistoryForAllDates()
    }
    
    func addDummyDataForTesting() {
        let calendar = Calendar.current
        let today = Date()
        
        for daysBack in 1...15 {
            if let pastDate = calendar.date(byAdding: .day, value: -daysBack, to: today) {
                let key = getDateKey(for: pastDate)
                
                if history[key] != nil {
                    print("Skipping day \(daysBack) ago (\(key)) - data already exists")
                    continue
                }
                
                var dummyExercises: [PlanItem] = []
                
                if daysBack == 8 {
                    print("Day \(daysBack) ago (\(getDateKey(for: pastDate))): NO exercises")
                    continue
                }
                
                if daysBack == 5 {
                    print("Creating 10 exercises for day \(daysBack) ago (\(getDateKey(for: pastDate)))")
                    for i in 1...10 {
                        let hour = 7 + i
                        let timeString = hour < 12 ? "\(hour):00 AM" : (hour == 12 ? "12:00 PM" : "\(hour - 12):00 PM")
                        
                        dummyExercises.append(PlanItem(
                            id: "dummy_\(key)_\(i)",
                            title: "Exercise \(i)",
                            subtitle: "Every Day",
                            time: timeString,
                            isCompleted: false,
                            description: "Test exercise \(i)",
                            hasReminder: true
                        ))
                    }
                    history[key] = DailyProgress(items: dummyExercises)
                    print("Added 10 MISSED exercises for \(getDateKey(for: pastDate))")
                    print("   Total: \(history[key]?.total ?? 0), Completed: \(history[key]?.completedCount ?? 0), Missed: \(history[key]?.missedItems.count ?? 0)")
                    saveHistory()
                    continue
                }
                
                dummyExercises.append(PlanItem(
                    id: "dummy_\(key)_1",
                    title: "Morning Stretches",
                    subtitle: "Every Day",
                    time: "8:00 AM",
                    isCompleted: daysBack % 2 == 0,
                    description: "Daily morning stretching routine",
                    hasReminder: true
                ))
                
                dummyExercises.append(PlanItem(
                    id: "dummy_\(key)_2",
                    title: "Arm Exercises",
                    subtitle: "Every Day",
                    time: "2:00 PM",
                    isCompleted: daysBack % 3 == 0,
                    description: "Arm strengthening exercises",
                    hasReminder: false
                ))
                
                if daysBack <= 10 {
                    dummyExercises.append(PlanItem(
                        id: "dummy_\(key)_3",
                        title: "Evening Walk",
                        subtitle: "Every Day",
                        time: "6:00 PM",
                        isCompleted: false,
                        description: "30 minute evening walk",
                        hasReminder: true
                    ))
                }
                
                if daysBack <= 7 {
                    dummyExercises.append(PlanItem(
                        id: "dummy_\(key)_4",
                        title: "Breathing Exercises",
                        subtitle: "Every Day",
                        time: "9:00 PM",
                        isCompleted: true,
                        description: "Deep breathing exercises",
                        hasReminder: false
                    ))
                }
                
                history[key] = DailyProgress(items: dummyExercises)
                print("Added \(dummyExercises.count) exercises for \(key)")
            }
        }
        
        saveHistory()
        
        if let testDate = calendar.date(byAdding: .day, value: -5, to: today) {
            let df = DateFormatter()
            df.dateFormat = "MMM d, yyyy"
            print("Check date \(df.string(from: testDate)) for 10 missed exercises")
        }
    }
    
    func loadAllData() {
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
    
    func currentDayPlan(for date: Date) -> [PlanItem] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E"
        let dayMatch = "Every \(dateFormatter.string(from: date))"
        
        let filteredItems = todaysPlan.filter { item in
            return item.subtitle == "Every Day" || item.subtitle == dayMatch
        }
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        timeFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        return filteredItems.sorted { item1, item2 in
            if let date1 = timeFormatter.date(from: item1.time),
               let date2 = timeFormatter.date(from: item2.time) {
                return date1 < date2
            }
            return item1.time < item2.time
        }
    }
    
    var currentDayPlan: [PlanItem] {
        return currentDayPlan(for: Date())
    }
    
    func togglePlanItem(id: String) {
        if let index = todaysPlan.firstIndex(where: { $0.id == id }) {
            todaysPlan[index].isCompleted.toggle()
            saveTodaysPlan()
            updateHistoryForToday()
        }
    }
    
    func addPlanItem(_ item: PlanItem) {
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
    
    func saveTodaysPlan() {
        do {
            let data = try JSONEncoder().encode(todaysPlan)
            UserDefaults.standard.set(data, forKey: todaysPlanStorageKey)
        } catch { print("Error saving plan: \(error)") }
    }
    
    func loadSavedPlan() {
        guard let data = UserDefaults.standard.data(forKey: todaysPlanStorageKey) else {
            self.todaysPlan = loadJSON(filename: "todaysPlan")
            return
        }
        do {
            self.todaysPlan = try JSONDecoder().decode([PlanItem].self, from: data)
        } catch { print("Error loading plan: \(error)") }
    }
    
    func updateHistoryForToday() {
        let key = getTodayDateString()
        let todayExercises = currentDayPlan
        if !todayExercises.isEmpty {
            history[key] = DailyProgress(items: todayExercises)
            saveHistory()
        }
    }
    
    func updateHistoryForAllDates() {
        let calendar = Calendar.current
        let today = Date()
        
        let startDate = getAppStartDate()
        
        let components = calendar.dateComponents([.day], from: startDate, to: today)
        guard let daysToCheck = components.day else { return }
        
        for daysBack in 0...daysToCheck {
            if let pastDate = calendar.date(byAdding: .day, value: -daysBack, to: today) {
                let key = getDateKey(for: pastDate)
                
                if history[key] != nil {
                    continue
                }
                
                let exercisesForDate = currentDayPlan(for: pastDate)
                
                if !exercisesForDate.isEmpty {
                    history[key] = DailyProgress(items: exercisesForDate)
                }
            }
        }
        saveHistory()
    }
    
    func getAppStartDate() -> Date {
        let startDateKey = "com.yourapp.startDate"
        
        if let savedTimestamp = UserDefaults.standard.object(forKey: startDateKey) as? TimeInterval {
            return Date(timeIntervalSince1970: savedTimestamp)
        } else {
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
    
    func getTodayDateString() -> String {
        return getDateKey(for: Date())
    }
    
    func getDateKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
