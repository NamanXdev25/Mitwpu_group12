//
//  FirestoreMigrationService.swift
//  BreastCancerApp
//
//  Created by Naman Bhansali on 01/03/26.
//

import Foundation

final class FirestoreMigrationService {
    static let shared = FirestoreMigrationService()

    private let migrationFlagKey = "did_run_firestore_migration_v1"

    private let localAppointments: AppointmentRepository
    private let cloudAppointments: AppointmentRepository

    private let localMedication: MedicationHistoryRepository
    private let cloudMedication: MedicationHistoryRepository

    private let localMemory: MemoryRepository
    private let cloudMemory: MemoryRepository

    private let localHydration: HydrationRepository
    private let cloudHydration: HydrationRepository

    private init(
        localAppointments: AppointmentRepository = UserDefaultsAppointmentRepository(),
        cloudAppointments: AppointmentRepository = FirestoreAppointmentRepository(),
        localMedication: MedicationHistoryRepository = UserDefaultsMedicationHistoryRepository(),
        cloudMedication: MedicationHistoryRepository = FirestoreMedicationHistoryRepository(),
        localMemory: MemoryRepository = UserDefaultsMemoryRepository(),
        cloudMemory: MemoryRepository = FirestoreMemoryRepository(),
        localHydration: HydrationRepository = UserDefaultsHydrationRepository(),
        cloudHydration: HydrationRepository = FirestoreHydrationRepository()
    ) {
        self.localAppointments = localAppointments
        self.cloudAppointments = cloudAppointments
        self.localMedication = localMedication
        self.cloudMedication = cloudMedication
        self.localMemory = localMemory
        self.cloudMemory = cloudMemory
        self.localHydration = localHydration
        self.cloudHydration = cloudHydration
    }

    func runIfNeeded() {
        let defaults = UserDefaults.standard
        guard defaults.bool(forKey: migrationFlagKey) == false else { return }

        cloudAppointments.saveAppointments(localAppointments.loadAppointments())
        cloudMedication.saveHistory(localMedication.loadHistory())
        cloudMemory.saveMemories(localMemory.loadMemories())
        cloudHydration.saveEntries(localHydration.loadEntries())

        defaults.set(true, forKey: migrationFlagKey)
    }
}

