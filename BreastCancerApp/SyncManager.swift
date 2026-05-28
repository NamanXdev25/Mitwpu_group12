import Foundation

final class SyncManager {
    static let shared = SyncManager()

    // MARK: - Dirty tracking

    enum DataDomain: String, CaseIterable {
        case appointments
        case medicationHistory
        case memories
        case hydration
        case symptoms
        case journal
        case breathing
        case profile
        case exercise
        case journey
    }

    private var dirtyDomains: Set<DataDomain> = []
    private let lock = NSLock()
    private var syncTimer: Timer?
    private var isPulling = false

    private init() {}

    // MARK: - Public API

    func markDirty(_ domain: DataDomain) {
        lock.lock()
        dirtyDomains.insert(domain)
        lock.unlock()
    }

    func pullAllAndStartTimer() {
        guard !isPulling else { return }
        isPulling = true

        let jitter = Double.random(in: 0 ... 20)

        DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + jitter) { [weak self] in
            self?.pullAll()
            DispatchQueue.main.async {
                self?.isPulling = false
                self?.startTimer()
            }
        }
    }

    func pushDirtyAndStopTimer() {
        stopTimer()
        pushDirty()
    }

    // MARK: - Pull (Cloud → Local)

    private func pullAll() {
        guard SupabaseConfiguration.current != nil else { return }

        let repos = resolveRepositories()

        let group = DispatchGroup()

        group.enter()
        repos.appointments.pullFromCloud { group.leave() }

        group.enter()
        repos.medication.pullFromCloud { group.leave() }

        group.enter()
        repos.memory.pullFromCloud { group.leave() }

        group.enter()
        repos.hydration.pullFromCloud { group.leave() }

        group.enter()
        repos.symptoms.pullFromCloud { group.leave() }

        group.enter()
        repos.journal.pullFromCloud { group.leave() }

        group.enter()
        repos.breathing.pullFromCloud { group.leave() }

        group.enter()
        repos.profile.pullFromCloud { group.leave() }

        group.enter()
        repos.exercise.pullFromCloud { group.leave() }

        group.enter()
        repos.journey.pullFromCloud { group.leave() }

        group.wait()
    }

    // MARK: - Push (Local → Cloud), only dirty

    private func pushDirty() {
        lock.lock()
        let domainsToSync = dirtyDomains
        dirtyDomains.removeAll()
        lock.unlock()

        guard !domainsToSync.isEmpty, SupabaseConfiguration.current != nil else { return }

        let repos = resolveRepositories()

        for domain in domainsToSync {
            switch domain {
            case .appointments: repos.appointments.pushToCloud()
            case .medicationHistory: repos.medication.pushToCloud()
            case .memories: repos.memory.pushToCloud()
            case .hydration: repos.hydration.pushToCloud()
            case .symptoms: repos.symptoms.pushToCloud()
            case .journal: repos.journal.pushToCloud()
            case .breathing: repos.breathing.pushToCloud()
            case .profile: repos.profile.pushToCloud()
            case .exercise: repos.exercise.pushToCloud()
            case .journey: repos.journey.pushToCloud()
            }
        }
    }

    // MARK: - Timer

    private func startTimer() {
        stopTimer()
        syncTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            DispatchQueue.global(qos: .utility).async {
                self?.pushDirty()
            }
        }
    }

    private func stopTimer() {
        syncTimer?.invalidate()
        syncTimer = nil
    }

    // MARK: - Repository resolution

    private struct Repos {
        let appointments: SupabaseAppointmentRepository
        let medication: SupabaseMedicationHistoryRepository
        let memory: SupabaseMemoryRepository
        let hydration: SupabaseHydrationRepository
        let symptoms: SupabaseSymptomRepository
        let journal: SupabaseJournalRepository
        let breathing: SupabaseBreathingRepository
        let profile: SupabaseProfileRepository
        let exercise: SupabaseExerciseRepository
        let journey: SupabaseJourneyRepository
    }

    private func resolveRepositories() -> Repos {
        guard let appointments = RepositoryFactory.makeAppointmentRepository() as? SupabaseAppointmentRepository,
              let medication = RepositoryFactory.makeMedicationHistoryRepository() as? SupabaseMedicationHistoryRepository,
              let memory = RepositoryFactory.makeMemoryRepository() as? SupabaseMemoryRepository,
              let hydration = RepositoryFactory.makeHydrationRepository() as? SupabaseHydrationRepository,
              let symptoms = RepositoryFactory.makeSymptomRepository() as? SupabaseSymptomRepository,
              let journal = RepositoryFactory.makeJournalRepository() as? SupabaseJournalRepository,
              let breathing = RepositoryFactory.makeBreathingRepository() as? SupabaseBreathingRepository,
              let profile = RepositoryFactory.makeProfileRepository() as? SupabaseProfileRepository,
              let exercise = RepositoryFactory.makeExerciseRepository() as? SupabaseExerciseRepository,
              let journey = RepositoryFactory.makeJourneyRepository() as? SupabaseJourneyRepository else {
            fatalError("Failed to cast repositories to Supabase implementations in SyncManager")
        }
        return Repos(
            appointments: appointments,
            medication: medication,
            memory: memory,
            hydration: hydration,
            symptoms: symptoms,
            journal: journal,
            breathing: breathing,
            profile: profile,
            exercise: exercise,
            journey: journey
        )
    }
}
