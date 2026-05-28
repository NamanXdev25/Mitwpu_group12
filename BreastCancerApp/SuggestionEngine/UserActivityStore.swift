import Foundation

struct ExerciseCompletionRecord: Codable, Hashable {
    let id: String
    let title: String
    let duration: String
    let completedAt: Date
    let planId: Int?

    init(id: String, title: String, duration: String, completedAt: Date, planId: Int? = nil) {
        self.id = id
        self.title = title
        self.duration = duration
        self.completedAt = completedAt
        self.planId = planId
    }
}

final class UserActivityStore {
    static let shared = UserActivityStore()
    private init() {
        load()
    }

    private let key = "uas_tapCounts"
    private var tapCounts: [String: Int] = [:]
    private var exerciseCompletions: [String: [ExerciseCompletionRecord]] = [:]
    private lazy var exerciseRepo: ExerciseRepository = RepositoryFactory.makeExerciseRepository()

    // MARK: - Recording taps

    func recordBreathingTap(title: String) {
        increment(key: "b:" + normalized(title))
    }

    func recordHobbyTap(title: String) {
        increment(key: "h:" + normalized(title))
    }

    // MARK: - Reading weights (returns 1, 2, or 3)

    func breathingWeight(for title: String) -> Int {
        weight(for: "b:" + normalized(title))
    }

    func hobbyWeight(for title: String) -> Int {
        weight(for: "h:" + normalized(title))
    }

    // MARK: - Exercise completion history

    func setExerciseCompleted(
        _ completed: Bool,
        exerciseID: String,
        title: String,
        duration: String,
        planId: Int? = nil,
        date: Date = Date()
    ) {
        let key = dateKey(for: date)
        var records = exerciseCompletions[key] ?? []

        records.removeAll { $0.id == exerciseID }

        if completed {
            records.append(
                ExerciseCompletionRecord(
                    id: exerciseID,
                    title: title,
                    duration: duration,
                    completedAt: date,
                    planId: planId
                )
            )
            records.sort { $0.completedAt > $1.completedAt }
        }

        if records.isEmpty {
            exerciseCompletions.removeValue(forKey: key)
        } else {
            exerciseCompletions[key] = records
        }

        save()
        NotificationCenter.default.post(name: .exerciseDataUpdated, object: nil)
    }

    func isExerciseCompleted(exerciseID: String, on date: Date = Date()) -> Bool {
        let key = dateKey(for: date)
        return exerciseCompletions[key]?.contains(where: { $0.id == exerciseID }) ?? false
    }

    func completedExerciseIDs(on date: Date = Date()) -> Set<String> {
        let key = dateKey(for: date)
        return Set((exerciseCompletions[key] ?? []).map(\.id))
    }

    func completedExercises(on date: Date) -> [ExerciseCompletionRecord] {
        let key = dateKey(for: date)
        return (exerciseCompletions[key] ?? []).sorted { $0.completedAt > $1.completedAt }
    }

    // MARK: - Top hobbies by engagement (for default state)

    func topHobbies(limit: Int = 3) -> [String] {
        tapCounts
            .filter { $0.key.hasPrefix("h:") }
            .sorted { $0.value > $1.value }
            .prefix(limit)
            .map { String($0.key.dropFirst(2)) }
    }

    // MARK: - Helpers

    private func increment(key k: String) {
        tapCounts[k, default: 0] += 1
        save()
    }

    private func weight(for k: String) -> Int {
        switch tapCounts[k] ?? 0 {
        case 0: return 1
        case 1 ... 2: return 2
        default: return 3
        }
    }

    private func normalized(_ s: String) -> String {
        s.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private func dateKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    private func save() {
        UserDefaults.standard.set(tapCounts, forKey: key)
        exerciseRepo.saveCompletions(exerciseCompletions)
    }

    private func load() {
        tapCounts = UserDefaults.standard.dictionary(forKey: key) as? [String: Int] ?? [:]
        exerciseCompletions = exerciseRepo.loadCompletions()
    }
}
