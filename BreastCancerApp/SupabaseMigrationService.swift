import Foundation

final class SupabaseMigrationService {
    static let shared = SupabaseMigrationService()

    private let migrationFlagKey = "did_run_supabase_migration_v1"

    private let localAppointments: AppointmentRepository
    private let cloudAppointments: AppointmentRepository

    private let localMedication: MedicationHistoryRepository
    private let cloudMedication: MedicationHistoryRepository

    private let localMemory: MemoryRepository
    private let cloudMemory: MemoryRepository

    private let localHydration: HydrationRepository
    private let cloudHydration: HydrationRepository

    private let localJournal: JournalRepository
    private let cloudJournal: JournalRepository

    private let localBreathing: BreathingRepository
    private let cloudBreathing: BreathingRepository

    private let localSymptoms: SymptomRepository
    private let cloudSymptoms: SymptomRepository

    private init(
        localAppointments: AppointmentRepository = UserDefaultsAppointmentRepository(),
        cloudAppointments: AppointmentRepository = SupabaseAppointmentRepository(),
        localMedication: MedicationHistoryRepository = UserDefaultsMedicationHistoryRepository(),
        cloudMedication: MedicationHistoryRepository = SupabaseMedicationHistoryRepository(),
        localMemory: MemoryRepository = UserDefaultsMemoryRepository(),
        cloudMemory: MemoryRepository = SupabaseMemoryRepository(),
        localHydration: HydrationRepository = UserDefaultsHydrationRepository(),
        cloudHydration: HydrationRepository = SupabaseHydrationRepository(),
        localJournal: JournalRepository = UserDefaultsJournalRepository(),
        cloudJournal: JournalRepository = SupabaseJournalRepository(),
        localBreathing: BreathingRepository = UserDefaultsBreathingRepository(),
        cloudBreathing: BreathingRepository = SupabaseBreathingRepository(),
        localSymptoms: SymptomRepository = UserDefaultsSymptomRepository(),
        cloudSymptoms: SymptomRepository = SupabaseSymptomRepository()
    ) {
        self.localAppointments = localAppointments
        self.cloudAppointments = cloudAppointments
        self.localMedication = localMedication
        self.cloudMedication = cloudMedication
        self.localMemory = localMemory
        self.cloudMemory = cloudMemory
        self.localHydration = localHydration
        self.cloudHydration = cloudHydration
        self.localJournal = localJournal
        self.cloudJournal = cloudJournal
        self.localBreathing = localBreathing
        self.cloudBreathing = cloudBreathing
        self.localSymptoms = localSymptoms
        self.cloudSymptoms = cloudSymptoms
    }

    func runIfNeeded() {
        guard SupabaseConfiguration.current != nil else { return }

        let defaults = UserDefaults.standard
        guard defaults.bool(forKey: migrationFlagKey) == false else { return }

        cloudAppointments.saveAppointments(localAppointments.loadAppointments())
        cloudMedication.saveHistory(localMedication.loadHistory())
        cloudMemory.saveMemories(localMemory.loadMemories())
        cloudHydration.saveEntries(localHydration.loadEntries())
        cloudJournal.saveEntries(localJournal.loadEntries())
        cloudBreathing.saveFavoriteTitles(localBreathing.loadFavoriteTitles())
        cloudSymptoms.saveLogs(localSymptoms.loadLogs())
        cloudSymptoms.saveUserSymptomIDs(localSymptoms.loadUserSymptomIDs())

        defaults.set(true, forKey: migrationFlagKey)
    }
}
