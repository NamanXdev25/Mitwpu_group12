//
//  FirestoreDTOs.swift
//  BreastCancerApp
//
//  Created by Naman Bhansali on 01/03/26.
//

import Foundation

// MARK: - Appointment

struct AppointmentFirestoreDTO: Codable {
    let id: String
    let title: String
    let category: String
    let date: String
    let time: String
    let reminderEnabled: Bool
    let note: String
    let colorIndex: Int
}

extension AppointmentItem {
    init(dto: AppointmentFirestoreDTO) {
        self.init(
            id: dto.id,
            title: dto.title,
            category: dto.category,
            date: dto.date,
            time: dto.time,
            reminderEnabled: dto.reminderEnabled,
            note: dto.note,
            colorIndex: dto.colorIndex
        )
    }

    func toDTO() -> AppointmentFirestoreDTO {
        AppointmentFirestoreDTO(
            id: id,
            title: title,
            category: category,
            date: date,
            time: time,
            reminderEnabled: reminderEnabled,
            note: note,
            colorIndex: colorIndex
        )
    }
}

// MARK: - Medication

struct MedicationFirestoreDTO: Codable {
    let id: String
    let name: String
    let note: String
    let time: String
    let repeatOption: String
    let isTaken: Bool
    let reminderEnabled: Bool
}

extension Medication {
    init(dto: MedicationFirestoreDTO) {
        self.init(
            id: dto.id,
            name: dto.name,
            note: dto.note,
            time: dto.time,
            repeatOption: dto.repeatOption,
            isTaken: dto.isTaken,
            reminderEnabled: dto.reminderEnabled
        )
    }

    func toDTO() -> MedicationFirestoreDTO {
        MedicationFirestoreDTO(
            id: id,
            name: name,
            note: note,
            time: time,
            repeatOption: repeatOption,
            isTaken: isTaken,
            reminderEnabled: reminderEnabled
        )
    }
}

// MARK: - Medication History

struct MedicationHistoryEntryFirestoreDTO: Codable {
    let id: String
    let dateEpoch: TimeInterval
    let medications: [MedicationFirestoreDTO]
    let taken: Int
    let goal: Int
}

extension MedicationHistoryEntry {
    init(dto: MedicationHistoryEntryFirestoreDTO) {
        self.init(
            id: dto.id,
            date: Date(timeIntervalSince1970: dto.dateEpoch),
            medications: dto.medications.map(Medication.init(dto:)),
            taken: dto.taken,
            goal: dto.goal
        )
    }

    func toDTO() -> MedicationHistoryEntryFirestoreDTO {
        MedicationHistoryEntryFirestoreDTO(
            id: id,
            dateEpoch: date.timeIntervalSince1970,
            medications: medications.map { $0.toDTO() },
            taken: taken,
            goal: goal
        )
    }
}

// MARK: - Memory

struct MemoryFirestoreDTO: Codable {
    let id: String
    let imageDataBase64: String?
    let dateEpoch: TimeInterval
    let note: String?
}

extension Memory {
    init(dto: MemoryFirestoreDTO) {
        let data = dto.imageDataBase64.flatMap { Data(base64Encoded: $0) }
        self.init(
            id: dto.id,
            imageData: data,
            date: Date(timeIntervalSince1970: dto.dateEpoch),
            note: dto.note
        )
    }

    func toDTO() -> MemoryFirestoreDTO {
        MemoryFirestoreDTO(
            id: id,
            imageDataBase64: imageData?.base64EncodedString(),
            dateEpoch: date.timeIntervalSince1970,
            note: note
        )
    }
}

// MARK: - Symptom Log

struct SymptomLogFirestoreDTO: Codable {
    let id: String
    let symptomId: String
    let symptomName: String
    let severity: Int
    let note: String
    let timestampEpoch: TimeInterval
}

extension SymptomLog {
    init(dto: SymptomLogFirestoreDTO) {
        self.init(
            id: dto.id,
            symptomId: dto.symptomId,
            symptomName: dto.symptomName,
            severity: dto.severity,
            note: dto.note,
            timestamp: Date(timeIntervalSince1970: dto.timestampEpoch)
        )
    }

    func toDTO() -> SymptomLogFirestoreDTO {
        SymptomLogFirestoreDTO(
            id: id,
            symptomId: symptomId,
            symptomName: symptomName,
            severity: severity,
            note: note,
            timestampEpoch: timestamp.timeIntervalSince1970
        )
    }
}

// MARK: - Hydration Entry

struct HydrationEntryFirestoreDTO: Codable {
    let id: String
    let amountML: Int
    let timestampEpoch: TimeInterval
}

extension HydrationEntry {
    init(dto: HydrationEntryFirestoreDTO) {
        self.init(
            id: UUID(uuidString: dto.id) ?? UUID(),
            amountML: dto.amountML,
            timestamp: Date(timeIntervalSince1970: dto.timestampEpoch)
        )
    }

    func toDTO() -> HydrationEntryFirestoreDTO {
        HydrationEntryFirestoreDTO(
            id: id.uuidString,
            amountML: amountML,
            timestampEpoch: timestamp.timeIntervalSince1970
        )
    }
}
