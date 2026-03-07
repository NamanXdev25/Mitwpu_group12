import Foundation

struct AppointmentSupabaseRow: Codable {
    let id: UUID
    let user_id: UUID
    let title: String
    let doctor: String?
    let location: String?
    let note: String?
    let appointment_at: Date
    let reminder_enabled: Bool
    let created_at: Date?
    let updated_at: Date?
}

struct AppointmentReminderSupabaseRow: Codable {
    let id: UUID
    let user_id: UUID
    let appointment_id: UUID
    let offset_minutes: Int
    let created_at: Date?
}

struct MedicationHistorySnapshotSupabaseRow: Codable {
    let id: String
    let user_id: UUID
    let date_key: String
    let date_epoch: TimeInterval
    let medications: [MedicationFirestoreDTO]
    let taken: Int
    let goal: Int
    let updated_at: Date?
}

struct MedicationItemSupabaseRow: Codable {
    let id: String
    let user_id: UUID
    let date_key: String
    let medication_id: String
    let name: String
    let note: String
    let time: String
    let repeat_option: String
    let is_taken: Bool
    let reminder_enabled: Bool
    let updated_at: Date?
}

struct JournalSupabaseRow: Codable {
    let id: UUID
    let user_id: UUID
    let title: String
    let body: String
    let type: String
    let question: String?
    let category: String?
    let journal_date: Date
    let created_at: Date?
    let updated_at: Date?

    private enum CodingKeys: String, CodingKey {
        case id
        case user_id
        case title
        case body
        case type
        case question
        case category
        case journal_date
        case created_at
        case updated_at
    }

    init(
        id: UUID,
        user_id: UUID,
        title: String,
        body: String,
        type: String,
        question: String?,
        category: String?,
        journal_date: Date,
        created_at: Date?,
        updated_at: Date?
    ) {
        self.id = id
        self.user_id = user_id
        self.title = title
        self.body = body
        self.type = type
        self.question = question
        self.category = category
        self.journal_date = journal_date
        self.created_at = created_at
        self.updated_at = updated_at
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        user_id = try container.decode(UUID.self, forKey: .user_id)
        title = try container.decode(String.self, forKey: .title)
        body = try container.decode(String.self, forKey: .body)
        type = try container.decode(String.self, forKey: .type)
        question = try container.decodeIfPresent(String.self, forKey: .question)
        category = try container.decodeIfPresent(String.self, forKey: .category)
        journal_date = try container.decode(Date.self, forKey: .journal_date)
        created_at = try container.decodeIfPresent(Date.self, forKey: .created_at)
        updated_at = try container.decodeIfPresent(Date.self, forKey: .updated_at)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(user_id, forKey: .user_id)
        try container.encode(title, forKey: .title)
        try container.encode(body, forKey: .body)
        try container.encode(type, forKey: .type)
        if let question {
            try container.encode(question, forKey: .question)
        } else {
            try container.encodeNil(forKey: .question)
        }
        if let category {
            try container.encode(category, forKey: .category)
        } else {
            try container.encodeNil(forKey: .category)
        }
        try container.encode(journal_date, forKey: .journal_date)
        if let created_at {
            try container.encode(created_at, forKey: .created_at)
        } else {
            try container.encodeNil(forKey: .created_at)
        }
        if let updated_at {
            try container.encode(updated_at, forKey: .updated_at)
        } else {
            try container.encodeNil(forKey: .updated_at)
        }
    }
}

struct HydrationSupabaseRow: Codable {
    let id: UUID
    let user_id: UUID
    let amount_ml: Int
    let logged_at: Date
    let created_at: Date?
}

struct MemorySupabaseRow: Codable {
    let id: String
    let user_id: UUID
    let image_data_base64: String?
    let memory_date: Date
    let note: String?
    let created_at: Date?
}

struct SymptomLogSupabaseRow: Codable {
    let id: String
    let user_id: UUID
    let symptom_id: String
    let symptom_name: String
    let severity: Int
    let note: String
    let logged_at: Date
    let created_at: Date?
}

struct SymptomPreferenceSupabaseRow: Codable {
    let id: UUID
    let user_id: UUID
    let user_symptom_ids: [String]
    let updated_at: Date?
}

struct BreathingFavoriteSupabaseRow: Codable {
    let id: UUID
    let user_id: UUID
    let title: String
    let created_at: Date?
}

extension AppointmentItem {
    init?(supabaseRow: AppointmentSupabaseRow, reminderOffsets: [ReminderOffset]) {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "dd MMM yyyy"

        let timeFormatter = DateFormatter()
        timeFormatter.locale = Locale(identifier: "en_US_POSIX")
        timeFormatter.dateFormat = "h:mm a"

        let date = formatter.string(from: supabaseRow.appointment_at)
        let time = timeFormatter.string(from: supabaseRow.appointment_at)

        let headerParts = [supabaseRow.doctor, supabaseRow.location].compactMap { value -> String? in
            guard let value, !value.isEmpty else { return nil }
            return value
        }
        let header = headerParts.joined(separator: " | ")
        let noteBody = supabaseRow.note?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let note = [header, noteBody].filter { !$0.isEmpty }.joined(separator: "\n")

        self.init(
            id: supabaseRow.id.uuidString,
            title: supabaseRow.title,
            date: date,
            time: time,
            reminderEnabled: supabaseRow.reminder_enabled,
            reminderOffsets: reminderOffsets,
            note: note
        )
    }

    func toSupabaseRow(userId: UUID) -> AppointmentSupabaseRow? {
        guard let appointmentAt else { return nil }

        return AppointmentSupabaseRow(
            id: UUID(uuidString: id) ?? UUID(),
            user_id: userId,
            title: title,
            doctor: doctor.isEmpty ? nil : doctor,
            location: location.isEmpty ? nil : location,
            note: supabaseNote,
            appointment_at: appointmentAt,
            reminder_enabled: reminderEnabled,
            created_at: nil,
            updated_at: Date()
        )
    }
}

extension MedicationHistoryEntry {
    init(supabaseRow: MedicationHistorySnapshotSupabaseRow) {
        self.init(
            id: supabaseRow.id,
            date: Date(timeIntervalSince1970: supabaseRow.date_epoch),
            medications: supabaseRow.medications.map(Medication.init(dto:)),
            taken: supabaseRow.taken,
            goal: supabaseRow.goal
        )
    }

    func toSupabaseRow(userId: UUID, dateKey: String) -> MedicationHistorySnapshotSupabaseRow {
        let scheduledToday = medications.filter { $0.isScheduledFor(date: date) }
        let takenToday = scheduledToday.filter { $0.isTaken }.count

        return MedicationHistorySnapshotSupabaseRow(
            id: id,
            user_id: userId,
            date_key: dateKey,
            date_epoch: date.timeIntervalSince1970,
            medications: medications.map { $0.toDTO() },
            taken: takenToday,
            goal: scheduledToday.count,
            updated_at: Date()
        )
    }
}

extension Medication {
    func toSupabaseItemRow(userId: UUID, dateKey: String) -> MedicationItemSupabaseRow {
        MedicationItemSupabaseRow(
            id: "\(dateKey)#\(id)",
            user_id: userId,
            date_key: dateKey,
            medication_id: id,
            name: name,
            note: note,
            time: time,
            repeat_option: repeatOption,
            is_taken: isTaken,
            reminder_enabled: reminderEnabled,
            updated_at: Date()
        )
    }
}

extension JournalEntry {
    init(supabaseRow: JournalSupabaseRow) {
        self.init(
            id: supabaseRow.id,
            title: supabaseRow.title,
            body: supabaseRow.body,
            date: supabaseRow.journal_date,
            type: JournalType(rawValue: supabaseRow.type) ?? .regular,
            question: supabaseRow.question,
            category: supabaseRow.category
        )
    }

    func toSupabaseRow(userId: UUID) -> JournalSupabaseRow {
        JournalSupabaseRow(
            id: id,
            user_id: userId,
            title: title,
            body: body,
            type: type.rawValue,
            question: question,
            category: category,
            journal_date: date,
            created_at: nil,
            updated_at: Date()
        )
    }
}

extension HydrationEntry {
    init(supabaseRow: HydrationSupabaseRow) {
        self.init(id: supabaseRow.id, amountML: supabaseRow.amount_ml, timestamp: supabaseRow.logged_at)
    }

    func toSupabaseRow(userId: UUID) -> HydrationSupabaseRow {
        HydrationSupabaseRow(
            id: id,
            user_id: userId,
            amount_ml: amountML,
            logged_at: timestamp,
            created_at: nil
        )
    }
}

extension Memory {
    init(supabaseRow: MemorySupabaseRow) {
        let imageData = supabaseRow.image_data_base64.flatMap { Foundation.Data(base64Encoded: $0) }
        self.init(
            id: supabaseRow.id,
            imageData: imageData,
            date: supabaseRow.memory_date,
            note: supabaseRow.note
        )
    }

    func toSupabaseRow(userId: UUID) -> MemorySupabaseRow {
        MemorySupabaseRow(
            id: id,
            user_id: userId,
            image_data_base64: imageData?.base64EncodedString(),
            memory_date: date,
            note: note,
            created_at: nil
        )
    }
}

extension SymptomLog {
    init(supabaseRow: SymptomLogSupabaseRow) {
        self.init(
            id: supabaseRow.id,
            symptomId: supabaseRow.symptom_id,
            symptomName: supabaseRow.symptom_name,
            severity: supabaseRow.severity,
            note: supabaseRow.note,
            timestamp: supabaseRow.logged_at
        )
    }

    func toSupabaseRow(userId: UUID) -> SymptomLogSupabaseRow {
        SymptomLogSupabaseRow(
            id: id,
            user_id: userId,
            symptom_id: symptomId,
            symptom_name: symptomName,
            severity: severity,
            note: note,
            logged_at: timestamp,
            created_at: nil
        )
    }
}
