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
        let migratedSymptomLogs = removeLegacySampleSymptomLogs(from: localSymptoms.loadLogs())
        cloudSymptoms.saveLogs(migratedSymptomLogs)
        cloudSymptoms.saveUserSymptomIDs(localSymptoms.loadUserSymptomIDs())
        GardenManager.shared.syncWithCloudIfNeeded()

        defaults.set(true, forKey: migrationFlagKey)
    }

    private func removeLegacySampleSymptomLogs(from logs: [SymptomLog]) -> [SymptomLog] {
        guard !logs.isEmpty else { return logs }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        struct SeedSignature: Hashable {
            let symptomId: String
            let severity: Int
            let dayOffset: Int
        }

        let legacySeedSignatures: Set<SeedSignature> = [
            SeedSignature(symptomId: "nausea", severity: 1, dayOffset: 1),
            SeedSignature(symptomId: "pain", severity: 3, dayOffset: 1),
            SeedSignature(symptomId: "fatigue", severity: 3, dayOffset: 3),
            SeedSignature(symptomId: "headache", severity: 2, dayOffset: 3),
            SeedSignature(symptomId: "nausea", severity: 4, dayOffset: 5),
            SeedSignature(symptomId: "pain", severity: 2, dayOffset: 7),
            SeedSignature(symptomId: "fatigue", severity: 4, dayOffset: 7),
            SeedSignature(symptomId: "insomnia", severity: 3, dayOffset: 10),
            SeedSignature(symptomId: "nausea", severity: 2, dayOffset: 12),
            SeedSignature(symptomId: "appetite_loss", severity: 3, dayOffset: 12),
            SeedSignature(symptomId: "fatigue", severity: 3, dayOffset: 14),
            SeedSignature(symptomId: "pain", severity: 4, dayOffset: 14),
            SeedSignature(symptomId: "headache", severity: 1, dayOffset: 17),
            SeedSignature(symptomId: "nausea", severity: 3, dayOffset: 19),
            SeedSignature(symptomId: "fatigue", severity: 4, dayOffset: 21),
            SeedSignature(symptomId: "insomnia", severity: 2, dayOffset: 21),
            SeedSignature(symptomId: "pain", severity: 3, dayOffset: 24),
            SeedSignature(symptomId: "nausea", severity: 2, dayOffset: 26),
            SeedSignature(symptomId: "appetite_loss", severity: 4, dayOffset: 26),
            SeedSignature(symptomId: "fatigue", severity: 2, dayOffset: 28),
            SeedSignature(symptomId: "headache", severity: 3, dayOffset: 30),
            SeedSignature(symptomId: "pain", severity: 2, dayOffset: 30)
        ]

        var removalIndices = Set<Int>()

        for (index, log) in logs.enumerated() {
            let trimmedNote = log.note.trimmingCharacters(in: .whitespacesAndNewlines)
            guard trimmedNote.isEmpty else { continue }

            let logDay = calendar.startOfDay(for: log.timestamp)
            let dayOffset = calendar.dateComponents([.day], from: logDay, to: today).day ?? 0
            guard dayOffset >= 1 else { continue }

            let signature = SeedSignature(
                symptomId: log.symptomId.lowercased(),
                severity: log.severity,
                dayOffset: dayOffset
            )
            if legacySeedSignatures.contains(signature) {
                removalIndices.insert(index)
            }
        }

        guard removalIndices.count >= 8 else { return logs }

        return logs.enumerated().compactMap { index, log in
            removalIndices.contains(index) ? nil : log
        }
    }
}
