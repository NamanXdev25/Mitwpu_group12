import Foundation

struct AuthUserSupabaseRow: Codable {
    let user_id: UUID
    let email: String
    let password: String
    let is_logged_in: Bool
    let has_completed_onboarding: Bool
    let created_at: Date?
    let updated_at: Date?

    private enum CodingKeys: String, CodingKey {
        case user_id
        case email
        case password
        case is_logged_in
        case has_completed_onboarding
        case created_at
        case updated_at
    }

    init(
        user_id: UUID,
        email: String,
        password: String,
        is_logged_in: Bool,
        has_completed_onboarding: Bool,
        created_at: Date?,
        updated_at: Date?
    ) {
        self.user_id = user_id
        self.email = email
        self.password = password
        self.is_logged_in = is_logged_in
        self.has_completed_onboarding = has_completed_onboarding
        self.created_at = created_at
        self.updated_at = updated_at
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        user_id = try container.decode(UUID.self, forKey: .user_id)
        email = try container.decode(String.self, forKey: .email)
        password = try container.decode(String.self, forKey: .password)
        is_logged_in = try container.decodeIfPresent(Bool.self, forKey: .is_logged_in) ?? false
        has_completed_onboarding =
            try container.decodeIfPresent(Bool.self, forKey: .has_completed_onboarding) ?? false
        created_at = try container.decodeIfPresent(Date.self, forKey: .created_at)
        updated_at = try container.decodeIfPresent(Date.self, forKey: .updated_at)
    }
}

struct UserProfileSupabaseRow: Codable {
    let user_id: UUID
    let first_name: String
    let last_name: String
    let profile_image_base64: String?
    let diagnosis_date: String
    let gender: String
    let age: Int
    let cancer_stage: String
    let treatment_state: String
    let treatment_completion_date: String
    let exercise_notifications_enabled: Bool
    let hydration_notifications_enabled: Bool
    let appointments_notifications_enabled: Bool
    let medications_notifications_enabled: Bool
    let updated_at: Date?

    private enum CodingKeys: String, CodingKey {
        case user_id
        case first_name
        case last_name
        case profile_image_base64
        case diagnosis_date
        case gender
        case age
        case cancer_stage
        case treatment_state
        case treatment_completion_date
        case exercise_notifications_enabled
        case hydration_notifications_enabled
        case appointments_notifications_enabled
        case medications_notifications_enabled
        case updated_at
    }

    init(
        user_id: UUID,
        first_name: String,
        last_name: String,
        profile_image_base64: String?,
        diagnosis_date: String,
        gender: String,
        age: Int,
        cancer_stage: String,
        treatment_state: String,
        treatment_completion_date: String,
        exercise_notifications_enabled: Bool,
        hydration_notifications_enabled: Bool,
        appointments_notifications_enabled: Bool,
        medications_notifications_enabled: Bool,
        updated_at: Date?
    ) {
        self.user_id = user_id
        self.first_name = first_name
        self.last_name = last_name
        self.profile_image_base64 = profile_image_base64
        self.diagnosis_date = diagnosis_date
        self.gender = gender
        self.age = age
        self.cancer_stage = cancer_stage
        self.treatment_state = treatment_state
        self.treatment_completion_date = treatment_completion_date
        self.exercise_notifications_enabled = exercise_notifications_enabled
        self.hydration_notifications_enabled = hydration_notifications_enabled
        self.appointments_notifications_enabled = appointments_notifications_enabled
        self.medications_notifications_enabled = medications_notifications_enabled
        self.updated_at = updated_at
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        user_id = try container.decode(UUID.self, forKey: .user_id)
        first_name = try container.decodeIfPresent(String.self, forKey: .first_name) ?? "User"
        last_name = try container.decodeIfPresent(String.self, forKey: .last_name) ?? ""
        profile_image_base64 = try container.decodeIfPresent(String.self, forKey: .profile_image_base64)
        diagnosis_date = try container.decodeIfPresent(String.self, forKey: .diagnosis_date) ?? "NA"
        gender = try container.decodeIfPresent(String.self, forKey: .gender) ?? "Female"
        age = try container.decodeIfPresent(Int.self, forKey: .age) ?? 32
        cancer_stage = try container.decodeIfPresent(String.self, forKey: .cancer_stage) ?? "NA"
        treatment_state = try container.decodeIfPresent(String.self, forKey: .treatment_state) ?? "Unknown"
        treatment_completion_date =
            try container.decodeIfPresent(String.self, forKey: .treatment_completion_date) ?? ""
        exercise_notifications_enabled =
            try container.decodeIfPresent(Bool.self, forKey: .exercise_notifications_enabled) ?? false
        hydration_notifications_enabled =
            try container.decodeIfPresent(Bool.self, forKey: .hydration_notifications_enabled) ?? false
        appointments_notifications_enabled =
            try container.decodeIfPresent(Bool.self, forKey: .appointments_notifications_enabled) ?? false
        medications_notifications_enabled =
            try container.decodeIfPresent(Bool.self, forKey: .medications_notifications_enabled) ?? false
        updated_at = try container.decodeIfPresent(Date.self, forKey: .updated_at)
    }
}

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
    let medications: [MedicationDTO]
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

struct MedicationPlanSupabaseRow: Codable {
    let id: String
    let user_id: UUID
    let name: String
    let note: String
    let time: String
    let repeat_option: String
    let reminder_enabled: Bool
    let is_active: Bool
    let created_at: Date?
    let updated_at: Date?
}

struct MedicationDailyStatusSupabaseRow: Codable {
    let id: String
    let user_id: UUID
    let date_key: String
    let date_epoch: TimeInterval
    let medication_id: String
    let is_scheduled: Bool
    let is_taken: Bool
    let taken_at: Date?
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

struct HydrationDailySupabaseRow: Codable {
    let id: String
    let user_id: UUID
    let date_key: String
    let date_epoch: TimeInterval
    let consumed_ml: Int
    let goal_ml: Int
    let updated_at: Date?
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

struct GardenStateSupabaseRow: Codable {
    let id: UUID
    let user_id: UUID
    let coins: Int
    let unlocked_base_ids: [String]
    let selected_base_id: String
    let level_progress: GardenLevelProgress
    let updated_at: Date?

    private enum CodingKeys: String, CodingKey {
        case id
        case user_id
        case coins
        case unlocked_base_ids
        case selected_base_id
        case level_progress
        case updated_at
    }

    init(
        id: UUID,
        user_id: UUID,
        coins: Int,
        unlocked_base_ids: [String],
        selected_base_id: String,
        level_progress: GardenLevelProgress,
        updated_at: Date?
    ) {
        self.id = id
        self.user_id = user_id
        self.coins = coins
        self.unlocked_base_ids = unlocked_base_ids
        self.selected_base_id = selected_base_id
        self.level_progress = level_progress
        self.updated_at = updated_at
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        user_id = try container.decode(UUID.self, forKey: .user_id)
        coins = (try? container.decode(Int.self, forKey: .coins)) ?? 0
        unlocked_base_ids = (try? container.decode([String].self, forKey: .unlocked_base_ids)) ?? []
        selected_base_id = (try? container.decode(String.self, forKey: .selected_base_id)) ?? "classic"
        level_progress = (try? container.decode(GardenLevelProgress.self, forKey: .level_progress)) ?? .initial
        updated_at = (try? container.decodeIfPresent(Date.self, forKey: .updated_at)) ?? nil
    }
}

struct GardenBaseStateSupabaseRow: Codable {
    let id: String
    let user_id: UUID
    let base_id: String
    let is_base_unlocked: Bool
    let is_active: Bool
    let unlocked_item_ids: [String]
    let placed_items: [PlacedItem]
    let updated_at: Date?

    private enum CodingKeys: String, CodingKey {
        case id
        case user_id
        case base_id
        case is_base_unlocked
        case is_active
        case unlocked_item_ids
        case placed_items
        case updated_at
    }

    init(
        id: String,
        user_id: UUID,
        base_id: String,
        is_base_unlocked: Bool,
        is_active: Bool,
        unlocked_item_ids: [String],
        placed_items: [PlacedItem],
        updated_at: Date?
    ) {
        self.id = id
        self.user_id = user_id
        self.base_id = base_id
        self.is_base_unlocked = is_base_unlocked
        self.is_active = is_active
        self.unlocked_item_ids = unlocked_item_ids
        self.placed_items = placed_items
        self.updated_at = updated_at
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        user_id = try container.decode(UUID.self, forKey: .user_id)
        base_id = (try? container.decode(String.self, forKey: .base_id)) ?? "classic"
        is_base_unlocked = (try? container.decode(Bool.self, forKey: .is_base_unlocked)) ?? false
        is_active = (try? container.decode(Bool.self, forKey: .is_active)) ?? false
        unlocked_item_ids = (try? container.decode([String].self, forKey: .unlocked_item_ids)) ?? []
        placed_items = (try? container.decode([PlacedItem].self, forKey: .placed_items)) ?? []
        updated_at = (try? container.decodeIfPresent(Date.self, forKey: .updated_at)) ?? nil
    }
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
            id: "\(userId.uuidString)#\(dateKey)",
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
            id: "\(userId.uuidString)#\(dateKey)#\(id)",
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

    func toSupabasePlanRow(userId: UUID) -> MedicationPlanSupabaseRow {
        MedicationPlanSupabaseRow(
            id: "\(userId.uuidString)#\(id)",
            user_id: userId,
            name: name,
            note: note,
            time: time,
            repeat_option: repeatOption,
            reminder_enabled: reminderEnabled,
            is_active: true,
            created_at: nil,
            updated_at: Date()
        )
    }
}

extension MedicationHistoryEntry {
    func toSupabaseDailyStatusRows(userId: UUID, dateKey: String) -> [MedicationDailyStatusSupabaseRow] {
        medications
            .filter { $0.isScheduledFor(date: date) }
            .map { medication in
                MedicationDailyStatusSupabaseRow(
                    id: "\(userId.uuidString)#\(dateKey)#\(medication.id)",
                    user_id: userId,
                    date_key: dateKey,
                    date_epoch: date.timeIntervalSince1970,
                    medication_id: medication.id,
                    is_scheduled: true,
                    is_taken: medication.isTaken,
                    taken_at: nil,
                    updated_at: Date()
                )
            }
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
    init(supabaseDailyRow: HydrationDailySupabaseRow) {
        self.init(
            id: UUID(uuidString: supabaseDailyRow.id) ?? UUID(),
            amountML: supabaseDailyRow.consumed_ml,
            timestamp: supabaseDailyRow.updated_at ?? Date(timeIntervalSince1970: supabaseDailyRow.date_epoch)
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

extension ProfileUserProfile {
    init(supabaseRow: UserProfileSupabaseRow) {
        self.init(
            firstName: supabaseRow.first_name,
            lastName: supabaseRow.last_name,
            profileImageBase64: supabaseRow.profile_image_base64,
            diagnosisDate: supabaseRow.diagnosis_date,
            gender: supabaseRow.gender,
            age: supabaseRow.age,
            cancerStage: supabaseRow.cancer_stage,
            treatmentState: supabaseRow.treatment_state,
            treatmentCompletionDate: supabaseRow.treatment_completion_date,
            exerciseNotificationsEnabled: supabaseRow.exercise_notifications_enabled,
            hydrationNotificationsEnabled: supabaseRow.hydration_notifications_enabled,
            appointmentsNotificationsEnabled: supabaseRow.appointments_notifications_enabled,
            medicationsNotificationsEnabled: supabaseRow.medications_notifications_enabled
        )
    }

    func toSupabaseRow(userId: UUID) -> UserProfileSupabaseRow {
        UserProfileSupabaseRow(
            user_id: userId,
            first_name: firstName,
            last_name: lastName,
            profile_image_base64: profileImageBase64,
            diagnosis_date: diagnosisDate,
            gender: gender,
            age: age,
            cancer_stage: cancerStage,
            treatment_state: treatmentState,
            treatment_completion_date: treatmentCompletionDate,
            exercise_notifications_enabled: exerciseNotificationsEnabled,
            hydration_notifications_enabled: hydrationNotificationsEnabled,
            appointments_notifications_enabled: appointmentsNotificationsEnabled,
            medications_notifications_enabled: medicationsNotificationsEnabled,
            updated_at: Date()
        )
    }
}

// MARK: - Exercise Completion DTO

struct ExerciseCompletionSupabaseRow: Codable {
    let id: String
    let user_id: UUID
    let date_key: String
    let plan_id: Int
    let exercise_name: String
    let completed_at: Date
    let updated_at: Date?
}

struct ExerciseSelectedPlanSupabaseRow: Codable {
    let user_id: UUID
    let plan_id: Int
    let updated_at: Date?
}

extension ExerciseCompletionRecord {
    init(supabaseRow: ExerciseCompletionSupabaseRow) {
        // Extract the original composite id from the Supabase row's PK (format: userId#dateKey#originalId)
        let components = supabaseRow.id.components(separatedBy: "#")
        let originalId = components.count > 2 ? components[2...].joined(separator: "#") : (components.last ?? supabaseRow.id)

        self.init(
            id: originalId,
            title: supabaseRow.exercise_name,
            duration: "",
            completedAt: supabaseRow.completed_at,
            planId: supabaseRow.plan_id
        )
    }

    func toSupabaseRow(userId: UUID, dateKey: String) -> ExerciseCompletionSupabaseRow? {
        guard let planId else { return nil }
        return ExerciseCompletionSupabaseRow(
            id: "\(userId.uuidString)#\(dateKey)#\(id)",
            user_id: userId,
            date_key: dateKey,
            plan_id: planId,
            exercise_name: title,
            completed_at: completedAt,
            updated_at: Date()
        )
    }
}

// MARK: - Journey State DTO

struct JourneyStateSupabaseRow: Codable {
    let user_id: UUID
    let is_diagnosis_completed: Bool
    let is_wait_completed: Bool
    let is_treatment_completed: Bool
    let current_step_title: String
    let current_treatment_name: String
    let persisted_treatment_badge: String

    let diagnosis_date: Date?
    let days_until_return: Int?
    let symptoms_of_days_until_return: String
    let post_treatment_recovery_start_date: Date?
    let post_treatment_symptoms: String

    let updated_at: Date?

    enum CodingKeys: String, CodingKey {
        case user_id, is_diagnosis_completed, is_wait_completed, is_treatment_completed
        case current_step_title, current_treatment_name, persisted_treatment_badge
        case diagnosis_date, days_until_return, symptoms_of_days_until_return
        case post_treatment_recovery_start_date, post_treatment_symptoms, updated_at
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(user_id, forKey: .user_id)
        try container.encode(is_diagnosis_completed, forKey: .is_diagnosis_completed)
        try container.encode(is_wait_completed, forKey: .is_wait_completed)
        try container.encode(is_treatment_completed, forKey: .is_treatment_completed)
        try container.encode(current_step_title, forKey: .current_step_title)
        try container.encode(current_treatment_name, forKey: .current_treatment_name)
        try container.encode(persisted_treatment_badge, forKey: .persisted_treatment_badge)
        try container.encode(symptoms_of_days_until_return, forKey: .symptoms_of_days_until_return)
        try container.encode(post_treatment_symptoms, forKey: .post_treatment_symptoms)
        try container.encode(updated_at, forKey: .updated_at)

        if let diagnosis_date = diagnosis_date { try container.encode(diagnosis_date, forKey: .diagnosis_date) } else { try container.encodeNil(forKey: .diagnosis_date) }

        if let days_until_return = days_until_return { try container.encode(days_until_return, forKey: .days_until_return) } else { try container.encodeNil(forKey: .days_until_return) }

        if let post_treatment_recovery_start_date = post_treatment_recovery_start_date { try container.encode(post_treatment_recovery_start_date, forKey: .post_treatment_recovery_start_date) } else { try container.encodeNil(forKey: .post_treatment_recovery_start_date) }
    }
}

struct TreatmentPhaseSupabaseRow: Codable {
    let id: String
    let user_id: UUID
    let treatment_type: String
    let start_date: Date?
    let duration: String
    let status: String
    let is_saved: Bool
    let updated_at: Date?
}

extension PersistedJourneySnapshot {
    init(journeyRow: JourneyStateSupabaseRow, phaseRows: [TreatmentPhaseSupabaseRow]) {
        let decoder = JSONDecoder()

        let phaseStates: [PersistedPhaseState] = phaseRows.map { row in
            PersistedPhaseState(
                treatmentTypeRaw: row.treatment_type,
                startDate: row.start_date,
                duration: row.duration,
                isSaved: row.is_saved,
                statusRaw: row.status
            )
        }

        let waitSymptoms: [String]
        if let data = journeyRow.symptoms_of_days_until_return.data(using: .utf8),
           let decoded = try? decoder.decode([String].self, from: data) {
            waitSymptoms = decoded
        } else {
            waitSymptoms = []
        }

        let postSymptoms: [String]
        if let data = journeyRow.post_treatment_symptoms.data(using: .utf8),
           let decoded = try? decoder.decode([String].self, from: data) {
            postSymptoms = decoded
        } else {
            postSymptoms = []
        }

        let postTreatment = PersistedPostTreatmentState(
            selectedDate: journeyRow.post_treatment_recovery_start_date,
            selectedSymptoms: postSymptoms,
            isSaved: journeyRow.post_treatment_recovery_start_date != nil || !postSymptoms.isEmpty
        )

        self.init(
            isDiagnosisCompleted: journeyRow.is_diagnosis_completed,
            isWaitCompleted: journeyRow.is_wait_completed,
            isTreatmentCompleted: journeyRow.is_treatment_completed,
            currentStepTitle: journeyRow.current_step_title,
            currentTreatmentName: journeyRow.current_treatment_name,
            persistedTreatmentBadge: journeyRow.persisted_treatment_badge,
            phaseStates: phaseStates,
            postTreatment: postTreatment,
            diagnosisDate: journeyRow.diagnosis_date,
            waitDaysInput: journeyRow.days_until_return,
            waitSymptoms: waitSymptoms
        )
    }

    func toJourneySupabaseRow(userId: UUID) -> JourneyStateSupabaseRow {
        let encoder = JSONEncoder()

        let waitSymptomsJSON = (try? encoder.encode(waitSymptoms)).flatMap { String(data: $0, encoding: .utf8) } ?? "[]"
        let postSymptomsJSON = (try? encoder.encode(postTreatment.selectedSymptoms)).flatMap { String(data: $0, encoding: .utf8) } ?? "[]"

        return JourneyStateSupabaseRow(
            user_id: userId,
            is_diagnosis_completed: isDiagnosisCompleted,
            is_wait_completed: isWaitCompleted,
            is_treatment_completed: isTreatmentCompleted,
            current_step_title: currentStepTitle,
            current_treatment_name: currentTreatmentName,
            persisted_treatment_badge: persistedTreatmentBadge,

            diagnosis_date: diagnosisDate,
            days_until_return: waitDaysInput,
            symptoms_of_days_until_return: waitSymptomsJSON,
            post_treatment_recovery_start_date: postTreatment.selectedDate,
            post_treatment_symptoms: postSymptomsJSON,

            updated_at: Date()
        )
    }

    func toTreatmentPhaseRows(userId: UUID) -> [TreatmentPhaseSupabaseRow] {
        return phaseStates.enumerated().map { index, phase in
            TreatmentPhaseSupabaseRow(
                id: "\(userId.uuidString)#phase#\(index)",
                user_id: userId,
                treatment_type: phase.treatmentTypeRaw,
                start_date: phase.startDate,
                duration: phase.duration,
                status: phase.statusRaw,
                is_saved: phase.isSaved,
                updated_at: Date()
            )
        }
    }
}
