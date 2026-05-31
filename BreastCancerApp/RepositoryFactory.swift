import Foundation

enum RepositoryFactory {
    // MARK: - Cached singletons (prevents duplicate cloud syncs)

    private static var _appointment: AppointmentRepository?
    private static var _medication: MedicationHistoryRepository?
    private static var _memory: MemoryRepository?
    private static var _hydration: HydrationRepository?
    private static var _symptom: SymptomRepository?
    private static var _journal: JournalRepository?
    private static var _breathing: BreathingRepository?
    private static var _profile: ProfileRepository?
    private static var _exercise: ExerciseRepository?
    private static var _journey: JourneyRepository?

    /// Discards all cached repositories. 
    /// Call this when the underlying SupabaseUserContext.userId changes (e.g. after login/logout)
    /// so the next access gets a fresh instance with the correct user ID.
    static func reset() {
        _appointment = nil
        _medication = nil
        _memory = nil
        _hydration = nil
        _symptom = nil
        _journal = nil
        _breathing = nil
        _profile = nil
        _exercise = nil
        _journey = nil
    }

    // MARK: - Factory accessors

    static func makeAppointmentRepository() -> AppointmentRepository {
        if let repo = _appointment { return repo }
        let repo = SupabaseAppointmentRepository()
        _appointment = repo
        return repo
    }

    static func makeMedicationHistoryRepository() -> MedicationHistoryRepository {
        if let repo = _medication { return repo }
        let repo = SupabaseMedicationHistoryRepository()
        _medication = repo
        return repo
    }

    static func makeMemoryRepository() -> MemoryRepository {
        if let repo = _memory { return repo }
        let repo = SupabaseMemoryRepository()
        _memory = repo
        return repo
    }

    static func makeHydrationRepository() -> HydrationRepository {
        if let repo = _hydration { return repo }
        let repo = SupabaseHydrationRepository()
        _hydration = repo
        return repo
    }

    static func makeSymptomRepository() -> SymptomRepository {
        if let repo = _symptom { return repo }
        let repo = SupabaseSymptomRepository()
        _symptom = repo
        return repo
    }

    static func makeJournalRepository() -> JournalRepository {
        if let repo = _journal { return repo }
        let repo = SupabaseJournalRepository()
        _journal = repo
        return repo
    }

    static func makeBreathingRepository() -> BreathingRepository {
        if let repo = _breathing { return repo }
        let repo = SupabaseBreathingRepository()
        _breathing = repo
        return repo
    }

    static func makeProfileRepository() -> ProfileRepository {
        if let repo = _profile { return repo }
        let repo = SupabaseProfileRepository()
        _profile = repo
        return repo
    }

    static func makeExerciseRepository() -> ExerciseRepository {
        if let repo = _exercise { return repo }
        let repo = SupabaseExerciseRepository()
        _exercise = repo
        return repo
    }

    static func makeJourneyRepository() -> JourneyRepository {
        if let repo = _journey { return repo }
        let repo = SupabaseJourneyRepository()
        _journey = repo
        return repo
    }
}
