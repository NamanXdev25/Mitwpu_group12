import Foundation

enum RepositoryFactory {
    static func makeAppointmentRepository() -> AppointmentRepository {
        switch AppBackend.current {
        case .firestore:
            return FirestoreAppointmentRepository()
        case .supabase:
            return SupabaseAppointmentRepository()
        }
    }

    static func makeMedicationHistoryRepository() -> MedicationHistoryRepository {
        switch AppBackend.current {
        case .firestore:
            return FirestoreMedicationHistoryRepository()
        case .supabase:
            return SupabaseMedicationHistoryRepository()
        }
    }

    static func makeMemoryRepository() -> MemoryRepository {
        switch AppBackend.current {
        case .firestore:
            return FirestoreMemoryRepository()
        case .supabase:
            return SupabaseMemoryRepository()
        }
    }

    static func makeHydrationRepository() -> HydrationRepository {
        switch AppBackend.current {
        case .firestore:
            return FirestoreHydrationRepository()
        case .supabase:
            return SupabaseHydrationRepository()
        }
    }

    static func makeSymptomRepository() -> SymptomRepository {
        switch AppBackend.current {
        case .firestore:
            return FirestoreSymptomRepository()
        case .supabase:
            return SupabaseSymptomRepository()
        }
    }

    static func makeJournalRepository() -> JournalRepository {
        switch AppBackend.current {
        case .firestore:
            return FirestoreJournalRepository()
        case .supabase:
            return SupabaseJournalRepository()
        }
    }

    static func makeBreathingRepository() -> BreathingRepository {
        switch AppBackend.current {
        case .firestore:
            return FirestoreBreathingRepository()
        case .supabase:
            return SupabaseBreathingRepository()
        }
    }
}
