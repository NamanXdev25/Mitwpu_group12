//
//  PersistenceDTOs.swift
//  BreastCancerApp
//
//  Created by Codex on 08/03/26.
//

import Foundation

// MARK: - Appointment

struct AppointmentDTO: Codable {
    let id: String
    let title: String
    let date: String
    let time: String
    let reminderEnabled: Bool
    let reminderOffsets: [String]
    let note: String
}

extension AppointmentItem {
    init(dto: AppointmentDTO) {
        self.init(
            id: dto.id,
            title: dto.title,
            date: dto.date,
            time: dto.time,
            reminderEnabled: dto.reminderEnabled,
            reminderOffsets: dto.reminderOffsets.compactMap { ReminderOffset(rawValue: $0) },
            note: dto.note
        )
    }

    func toDTO() -> AppointmentDTO {
        AppointmentDTO(
            id: id,
            title: title,
            date: date,
            time: time,
            reminderEnabled: reminderEnabled,
            reminderOffsets: reminderOffsets.map { $0.rawValue },
            note: note
        )
    }
}

// MARK: - Medication

struct MedicationDTO: Codable {
    let id: String
    let name: String
    let note: String
    let time: String
    let repeatOption: String
    let isTaken: Bool
    let reminderEnabled: Bool
}

extension Medication {
    init(dto: MedicationDTO) {
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

    func toDTO() -> MedicationDTO {
        MedicationDTO(
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

struct MedicationHistoryEntryDTO: Codable {
    let id: String
    let dateEpoch: TimeInterval
    let medications: [MedicationDTO]
    let taken: Int
    let goal: Int
}

extension MedicationHistoryEntry {
    init(dto: MedicationHistoryEntryDTO) {
        self.init(
            id: dto.id,
            date: Date(timeIntervalSince1970: dto.dateEpoch),
            medications: dto.medications.map(Medication.init(dto:)),
            taken: dto.taken,
            goal: dto.goal
        )
    }

    func toDTO() -> MedicationHistoryEntryDTO {
        MedicationHistoryEntryDTO(
            id: id,
            dateEpoch: date.timeIntervalSince1970,
            medications: medications.map { $0.toDTO() },
            taken: taken,
            goal: goal
        )
    }
}

// MARK: - Memory

struct MemoryDTO: Codable {
    let id: String
    let imageDataBase64: String?
    let dateEpoch: TimeInterval
    let note: String?
}

extension Memory {
    init(dto: MemoryDTO) {
        let data = dto.imageDataBase64.flatMap { Data(base64Encoded: $0) }
        self.init(
            id: dto.id,
            imageData: data,
            date: Date(timeIntervalSince1970: dto.dateEpoch),
            note: dto.note
        )
    }

    func toDTO() -> MemoryDTO {
        MemoryDTO(
            id: id,
            imageDataBase64: imageData?.base64EncodedString(),
            dateEpoch: date.timeIntervalSince1970,
            note: note
        )
    }
}

// MARK: - Symptom Log

struct SymptomLogDTO: Codable {
    let id: String
    let symptomId: String
    let symptomName: String
    let severity: Int
    let note: String
    let timestampEpoch: TimeInterval
}

extension SymptomLog {
    init(dto: SymptomLogDTO) {
        self.init(
            id: dto.id,
            symptomId: dto.symptomId,
            symptomName: dto.symptomName,
            severity: dto.severity,
            note: dto.note,
            timestamp: Date(timeIntervalSince1970: dto.timestampEpoch)
        )
    }

    func toDTO() -> SymptomLogDTO {
        SymptomLogDTO(
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

struct HydrationEntryDTO: Codable {
    let id: String
    let amountML: Int
    let timestampEpoch: TimeInterval
}

extension HydrationEntry {
    init(dto: HydrationEntryDTO) {
        self.init(
            id: UUID(uuidString: dto.id) ?? UUID(),
            amountML: dto.amountML,
            timestamp: Date(timeIntervalSince1970: dto.timestampEpoch)
        )
    }

    func toDTO() -> HydrationEntryDTO {
        HydrationEntryDTO(
            id: id.uuidString,
            amountML: amountML,
            timestampEpoch: timestamp.timeIntervalSince1970
        )
    }
}

// MARK: - Journal

struct JournalEntryDTO: Codable {
    let id: String
    let title: String
    let body: String
    let dateEpoch: TimeInterval
    let type: String
    let question: String?
    let category: String?
}

extension JournalEntry {
    init(dto: JournalEntryDTO) {
        self.init(
            id: UUID(uuidString: dto.id) ?? UUID(),
            title: dto.title,
            body: dto.body,
            date: Date(timeIntervalSince1970: dto.dateEpoch),
            type: JournalType(rawValue: dto.type) ?? .regular,
            question: dto.question,
            category: dto.category
        )
    }

    func toDTO() -> JournalEntryDTO {
        JournalEntryDTO(
            id: id.uuidString,
            title: title,
            body: body,
            dateEpoch: date.timeIntervalSince1970,
            type: type.rawValue,
            question: question,
            category: category
        )
    }
}
