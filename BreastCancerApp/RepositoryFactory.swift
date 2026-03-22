import Foundation

enum RepositoryFactory {
    static func makeAppointmentRepository() -> AppointmentRepository {
        SupabaseAppointmentRepository()
    }

    static func makeMedicationHistoryRepository() -> MedicationHistoryRepository {
        SupabaseMedicationHistoryRepository()
    }

    static func makeMemoryRepository() -> MemoryRepository {
        SupabaseMemoryRepository()
    }

    static func makeHydrationRepository() -> HydrationRepository {
        SupabaseHydrationRepository()
    }

    static func makeSymptomRepository() -> SymptomRepository {
        SupabaseSymptomRepository()
    }

    static func makeJournalRepository() -> JournalRepository {
        SupabaseJournalRepository()
    }

    static func makeBreathingRepository() -> BreathingRepository {
        SupabaseBreathingRepository()
    }

    static func makeProfileRepository() -> ProfileRepository {
        SupabaseProfileRepository()
    }

    static func makeExerciseRepository() -> ExerciseRepository {
        SupabaseExerciseRepository()
    }

    static func makeJourneyRepository() -> JourneyRepository {
        SupabaseJourneyRepository()
    }
}
