import Foundation

enum RepositoryFactory {
    // MARK: - Cached singletons (prevents duplicate cloud syncs)

    private static let _appointment: AppointmentRepository = SupabaseAppointmentRepository()
    private static let _medication: MedicationHistoryRepository = SupabaseMedicationHistoryRepository()
    private static let _memory: MemoryRepository = SupabaseMemoryRepository()
    private static let _hydration: HydrationRepository = SupabaseHydrationRepository()
    private static let _symptom: SymptomRepository = SupabaseSymptomRepository()
    private static let _journal: JournalRepository = SupabaseJournalRepository()
    private static let _breathing: BreathingRepository = SupabaseBreathingRepository()
    private static let _profile: ProfileRepository = SupabaseProfileRepository()
    private static let _exercise: ExerciseRepository = SupabaseExerciseRepository()
    private static let _journey: JourneyRepository = SupabaseJourneyRepository()

    // MARK: - Factory accessors

    static func makeAppointmentRepository() -> AppointmentRepository {
        _appointment
    }

    static func makeMedicationHistoryRepository() -> MedicationHistoryRepository {
        _medication
    }

    static func makeMemoryRepository() -> MemoryRepository {
        _memory
    }

    static func makeHydrationRepository() -> HydrationRepository {
        _hydration
    }

    static func makeSymptomRepository() -> SymptomRepository {
        _symptom
    }

    static func makeJournalRepository() -> JournalRepository {
        _journal
    }

    static func makeBreathingRepository() -> BreathingRepository {
        _breathing
    }

    static func makeProfileRepository() -> ProfileRepository {
        _profile
    }

    static func makeExerciseRepository() -> ExerciseRepository {
        _exercise
    }

    static func makeJourneyRepository() -> JourneyRepository {
        _journey
    }
}
