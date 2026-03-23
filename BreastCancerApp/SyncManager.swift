import Foundation

/// Central coordinator for all Supabase cloud sync.
/// Local UserDefaults = source of truth during runtime.
/// Supabase = backup + persistence.
///
/// Pull on app start, push only dirty repos every 60s or on background.
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

    /// Mark a domain as needing a push to cloud.
    func markDirty(_ domain: DataDomain) {
        lock.lock()
        dirtyDomains.insert(domain)
        lock.unlock()
    }

    /// Called on app foreground. Pulls all data from cloud into local, then starts the periodic sync timer.
    func pullAllAndStartTimer() {
        guard !isPulling else { return }
        isPulling = true

        DispatchQueue.global(qos: .utility).async { [weak self] in
            self?.pullAll()
            DispatchQueue.main.async {
                self?.isPulling = false
                self?.startTimer()
            }
        }
    }

    /// Called on app background. Pushes all dirty repos and stops the timer.
    func pushDirtyAndStopTimer() {
        stopTimer()
        pushDirty()
    }

    // MARK: - Pull (Cloud → Local)

    private func pullAll() {
        guard SupabaseConfiguration.current != nil else { return }

        let repos = resolveRepositories()

        // Pull each domain. These are synchronous-ish (they use completion blocks internally)
        // but we fire them all concurrently and wait.
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
            case .appointments:   repos.appointments.pushToCloud()
            case .medicationHistory: repos.medication.pushToCloud()
            case .memories:       repos.memory.pushToCloud()
            case .hydration:      repos.hydration.pushToCloud()
            case .symptoms:       repos.symptoms.pushToCloud()
            case .journal:        repos.journal.pushToCloud()
            case .breathing:      repos.breathing.pushToCloud()
            case .profile:        repos.profile.pushToCloud()
            case .exercise:       repos.exercise.pushToCloud()
            case .journey:        repos.journey.pushToCloud()
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
        // RepositoryFactory returns cached singletons, so we can safely cast
        Repos(
            appointments: RepositoryFactory.makeAppointmentRepository() as! SupabaseAppointmentRepository,
            medication: RepositoryFactory.makeMedicationHistoryRepository() as! SupabaseMedicationHistoryRepository,
            memory: RepositoryFactory.makeMemoryRepository() as! SupabaseMemoryRepository,
            hydration: RepositoryFactory.makeHydrationRepository() as! SupabaseHydrationRepository,
            symptoms: RepositoryFactory.makeSymptomRepository() as! SupabaseSymptomRepository,
            journal: RepositoryFactory.makeJournalRepository() as! SupabaseJournalRepository,
            breathing: RepositoryFactory.makeBreathingRepository() as! SupabaseBreathingRepository,
            profile: RepositoryFactory.makeProfileRepository() as! SupabaseProfileRepository,
            exercise: RepositoryFactory.makeExerciseRepository() as! SupabaseExerciseRepository,
            journey: RepositoryFactory.makeJourneyRepository() as! SupabaseJourneyRepository
        )
    }
}
