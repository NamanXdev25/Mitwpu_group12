//
//  AppModels.swift
//  BreastCancerApp
//
//  Created by Naman Bhansali on 01/03/26.
//

import Foundation
import CoreGraphics

// MARK: - Care

enum CareSectionType: Int, CaseIterable {
    case todayHeader = 0
    case hydration
    case medication
    case exercise
    case symptoms
    case appointmentHeader
    case appointments
    case healthInsights
}

enum CareItemType {
    case header(title: String, showManage: Bool)
    case hydration
    case medication(title: String, status: String, imageName: String?)
    case exercise(title: String, duration: String, imageName: String?)
    case symptoms(title: String, loggedSymptoms: [String])
    case appointment(month: String, day: String, title: String, doctor: String, time: String)
    case healthInsights
}

struct CareItem: Hashable {
    let id: UUID
    let type: CareItemType

    static func == (lhs: CareItem, rhs: CareItem) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension CareItemType: Hashable {
    static func == (lhs: CareItemType, rhs: CareItemType) -> Bool {
        switch (lhs, rhs) {
        case (.header(let lTitle, let lShow), .header(let rTitle, let rShow)):
            return lTitle == rTitle && lShow == rShow
        case (.hydration, .hydration):
            return true
        case (.medication(let lTitle, let lStatus, let lImage), .medication(let rTitle, let rStatus, let rImage)):
            return lTitle == rTitle && lStatus == rStatus && lImage == rImage
        case (.exercise(let lTitle, let lDuration, let lImage), .exercise(let rTitle, let rDuration, let rImage)):
            return lTitle == rTitle && lDuration == rDuration && lImage == rImage
        case (.symptoms(let lTitle, let lSymptoms), .symptoms(let rTitle, let rSymptoms)):
            return lTitle == rTitle && lSymptoms == rSymptoms
        case (.appointment(let lMonth, let lDay, let lTitle, let lDoctor, let lTime),
              .appointment(let rMonth, let rDay, let rTitle, let rDoctor, let rTime)):
            return lMonth == rMonth && lDay == rDay && lTitle == rTitle && lDoctor == rDoctor && lTime == rTime
        case (.healthInsights, .healthInsights):
            return true
        default:
            return false
        }
    }

    func hash(into hasher: inout Hasher) {
        switch self {
        case .header(let title, let showManage):
            hasher.combine("header")
            hasher.combine(title)
            hasher.combine(showManage)
        case .hydration:
            hasher.combine("hydration")
        case .medication(let title, let status, let imageName):
            hasher.combine("medication")
            hasher.combine(title)
            hasher.combine(status)
            hasher.combine(imageName)
        case .exercise(let title, let duration, let imageName):
            hasher.combine("exercise")
            hasher.combine(title)
            hasher.combine(duration)
            hasher.combine(imageName)
        case .symptoms(let title, let loggedSymptoms):
            hasher.combine("symptoms")
            hasher.combine(title)
            hasher.combine(loggedSymptoms)
        case .appointment(let month, let day, let title, let doctor, let time):
            hasher.combine("appointment")
            hasher.combine(month)
            hasher.combine(day)
            hasher.combine(title)
            hasher.combine(doctor)
            hasher.combine(time)
        case .healthInsights:
            hasher.combine("healthInsights")
        }
    }
}

struct CareModel {
    static let sampleSymptoms = ["Fatigue", "Nausea", "Pain", "+2"]
    static let sampleAppointments = [
        (month: "FEB", day: "15", title: "Oncology Checkup", doctor: "Dr. Sarah Johnson", time: "10:00 AM"),
        (month: "FEB", day: "22", title: "Blood Work", doctor: "Lab Services", time: "9:00 AM")
    ]
}

// MARK: - Home

enum HomeSectionType: Int, CaseIterable {
    case title = 0
    case quote
    case mood
    case journal
    case suggestion
    case articles
}

struct HomeItem: Hashable {
    let id = UUID()
    let type: ItemType

    enum ItemType: Hashable {
        case title
        case quote(String)
        case mood
        case journal(Suggestion)
        case suggestion(Suggestion)
        case article(Article)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: HomeItem, rhs: HomeItem) -> Bool {
        lhs.id == rhs.id
    }
}


struct Mood: Hashable {
    let imageName: String
    let title: String
}

struct Suggestion: Hashable {
    let imageName: String
    let title: String
    let subtitle: String
}

struct Article: Hashable {
    let imageName: String
    let title: String
    let subtitle: String
}

struct HomeMemoryModel {
    let imageName: String
    let date: String
    let description: String
}

struct HomeMoodSuggestionRoot: Decodable {
    let moods: [String: HomeMoodSuggestionContent]
}

struct HomeMoodSuggestionContent: Decodable {
    let breathing: [HomeMoodSuggestionItem]
    let journaling: [HomeMoodSuggestionItem]
    let hobby: [HomeMoodSuggestionItem]
}

struct HomeMoodSuggestionItem: Decodable {
    let title: String
    let description: String?
    let image: String?

    enum CodingKeys: String, CodingKey {
        case title
        case description
        case subtitle
        case image
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decodeIfPresent(String.self, forKey: .description)
            ?? container.decodeIfPresent(String.self, forKey: .subtitle)
        image = try container.decodeIfPresent(String.self, forKey: .image)
    }
}


// MARK: - Appointments

struct AppointmentItem {
    let id: String
    let title: String
    let category: String
    let date: String
    let time: String
    let reminderEnabled: Bool
    let note: String
    let colorIndex: Int
}

enum AppointmentType: Int, CaseIterable {
    case chemotherapy = 0
    case doctorVisit = 1

    var title: String {
        switch self {
        case .chemotherapy: return "Chemotherapy"
        case .doctorVisit: return "     Doctor Visit"
        }
    }

    var pickerTitle: String {
        switch self {
        case .chemotherapy: return "Chemotherapy"
        case .doctorVisit: return "Doctor Visit"
        }
    }
}


struct AppointmentItemCodable: Codable {
    let id: String
    let title: String
    let category: String
    let date: String
    let time: String
    let reminderEnabled: Bool
    let note: String
    let colorIndex: Int

    init(from appointment: AppointmentItem) {
        self.id = appointment.id
        self.title = appointment.title
        self.category = appointment.category
        self.date = appointment.date
        self.time = appointment.time
        self.reminderEnabled = appointment.reminderEnabled
        self.note = appointment.note
        self.colorIndex = appointment.colorIndex
    }

    func toAppointmentItem() -> AppointmentItem {
        AppointmentItem(
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

// MARK: - Articles

struct ArticleModel: Decodable {
    let id: String
    let title: String
    let subtitle: String
    let imageName: String
    let content: String
}

struct ArticlesResponse: Decodable {
    let articles: [ArticleModel]
}

// MARK: - Breathing / Mindfulness

struct BreathingSession {
    let title: String
    let category: String
    let duration: String
    let imageName: String
    var isFavorite: Bool
    let videoFileName: String
}

struct MindfulnessSlide {
    let title: String
    let description: String
    let buttonText: String
    let action: SlideAction
}

enum SlideAction {
    case begin
    case addPhoto
}

struct MindfulnessJSONRoot: Decodable {
    let moods: [String: MoodContent]
}

struct MoodContent: Decodable {
    let intro: SlideCardJSON
    let breathing: [SlideCardJSON]
    let journaling: [SlideCardJSON]
    let hobby: [SlideCardJSON]
}

struct SlideCardJSON: Decodable {
    let title: String
    let description: String
    let buttonText: String?
}

// MARK: - Journal

enum JournalType: String, Codable {
    case regular
    case guided
}

struct JournalEntry: Hashable, Identifiable, Codable {
    let id: UUID
    var title: String
    var body: String
    var date: Date
    var type: JournalType
    var question: String?
    var category: String?

    init(
        id: UUID = UUID(),
        title: String,
        body: String,
        date: Date = Date(),
        type: JournalType,
        question: String? = nil,
        category: String? = nil
    ) {
        self.id = id
        self.title = title
        self.body = body
        self.date = date
        self.type = type
        self.question = question
        self.category = category
    }
}

extension JournalEntry {
    var content: String { body }

    var dateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    var formattedDateTitle: String {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")

        let thisYear = calendar.component(.year, from: Date())
        let entryYear = calendar.component(.year, from: date)

        if thisYear == entryYear {
            formatter.setLocalizedDateFormatFromTemplate("EEE, MMM d")
        } else {
            formatter.setLocalizedDateFormatFromTemplate("MMM d, yyyy")
        }
        return formatter.string(from: date)
    }
}

// MARK: - Medication

struct Medication: Codable, Identifiable {
    let id: String
    var name: String
    var note: String
    var time: String
    var repeatOption: String
    var isTaken: Bool
    var reminderEnabled: Bool

    init(
        id: String = UUID().uuidString,
        name: String,
        note: String,
        time: String,
        repeatOption: String,
        isTaken: Bool = false,
        reminderEnabled: Bool = true
    ) {
        self.id = id
        self.name = name
        self.note = note
        self.time = time
        self.repeatOption = repeatOption
        self.isTaken = isTaken
        self.reminderEnabled = reminderEnabled
    }

    func isScheduledFor(date: Date) -> Bool {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)

        if repeatOption == "Every Day" {
            return true
        }

        let weekdayMap: [Int: String] = [
            1: "Every Sun",
            2: "Every Mon",
            3: "Every Tue",
            4: "Every Wed",
            5: "Every Thu",
            6: "Every Fri",
            7: "Every Sat"
        ]

        return repeatOption == weekdayMap[weekday]
    }
}

struct MedicationHistoryEntry: Codable, Identifiable {
    let id: String
    let date: Date
    var medications: [Medication]
    var taken: Int
    var goal: Int

    init(
        id: String = UUID().uuidString,
        date: Date,
        medications: [Medication],
        taken: Int,
        goal: Int
    ) {
        self.id = id
        self.date = date
        self.medications = medications
        self.taken = taken
        self.goal = goal
    }
}


// MARK: - Symptoms

struct Symptom: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    var isInUserList: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case isInUserList = "isInUserListByDefault"
    }
}

struct SymptomsData: Codable {
    let symptoms: [Symptom]
}

struct SymptomLog: Codable, Identifiable {
    let id: String
    let symptomId: String
    let symptomName: String
    let severity: Int
    let note: String
    let timestamp: Date

    init(
        id: String = UUID().uuidString,
        symptomId: String,
        symptomName: String,
        severity: Int,
        note: String = "",
        timestamp: Date = Date()
    ) {
        self.id = id
        self.symptomId = symptomId
        self.symptomName = symptomName
        self.severity = severity
        self.note = note
        self.timestamp = timestamp
    }
}


// MARK: - Insights

enum InsightType: String, Codable {
    case hydration, exercise, medication, symptoms
}

struct HealthInsight: Codable, Identifiable {
    let id: String
    let type: InsightType
    let title: String
    let subtitle: String?
    let mainValue: String?
    let completedValue: String?
    let secondaryValue: String?
    let medicationTaken: String?
    let medicationMissed: String?
    let detailText: String?
    let dailyValues: [Int]?

    enum CodingKeys: String, CodingKey {
        case id
        case type
        case title
        case subtitle
        case mainValue
        case completedValue
        case secondaryValue
        case medicationTaken
        case medicationMissed
        case detailText
        case dailyValues
    }

    init(
        id: String? = nil,
        type: InsightType,
        title: String,
        subtitle: String? = nil,
        mainValue: String? = nil,
        completedValue: String? = nil,
        secondaryValue: String? = nil,
        medicationTaken: String? = nil,
        medicationMissed: String? = nil,
        detailText: String? = nil,
        dailyValues: [Int]? = nil
    ) {
        self.type = type
        self.title = title
        self.subtitle = subtitle
        self.mainValue = mainValue
        self.completedValue = completedValue
        self.secondaryValue = secondaryValue
        self.medicationTaken = medicationTaken
        self.medicationMissed = medicationMissed
        self.detailText = detailText
        self.dailyValues = dailyValues
        self.id = id ?? HealthInsight.makeStableId(
            type: type,
            title: title,
            subtitle: subtitle,
            mainValue: mainValue,
            completedValue: completedValue,
            secondaryValue: secondaryValue,
            medicationTaken: medicationTaken,
            medicationMissed: medicationMissed,
            detailText: detailText,
            dailyValues: dailyValues
        )
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let type = try container.decode(InsightType.self, forKey: .type)
        let title = try container.decode(String.self, forKey: .title)
        let subtitle = try container.decodeIfPresent(String.self, forKey: .subtitle)
        let mainValue = try container.decodeIfPresent(String.self, forKey: .mainValue)
        let completedValue = try container.decodeIfPresent(String.self, forKey: .completedValue)
        let secondaryValue = try container.decodeIfPresent(String.self, forKey: .secondaryValue)
        let medicationTaken = try container.decodeIfPresent(String.self, forKey: .medicationTaken)
        let medicationMissed = try container.decodeIfPresent(String.self, forKey: .medicationMissed)
        let detailText = try container.decodeIfPresent(String.self, forKey: .detailText)
        let dailyValues = try container.decodeIfPresent([Int].self, forKey: .dailyValues)

        self.type = type
        self.title = title
        self.subtitle = subtitle
        self.mainValue = mainValue
        self.completedValue = completedValue
        self.secondaryValue = secondaryValue
        self.medicationTaken = medicationTaken
        self.medicationMissed = medicationMissed
        self.detailText = detailText
        self.dailyValues = dailyValues
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
            ?? HealthInsight.makeStableId(
                type: type,
                title: title,
                subtitle: subtitle,
                mainValue: mainValue,
                completedValue: completedValue,
                secondaryValue: secondaryValue,
                medicationTaken: medicationTaken,
                medicationMissed: medicationMissed,
                detailText: detailText,
                dailyValues: dailyValues
            )
    }

    private static func makeStableId(
        type: InsightType,
        title: String,
        subtitle: String?,
        mainValue: String?,
        completedValue: String?,
        secondaryValue: String?,
        medicationTaken: String?,
        medicationMissed: String?,
        detailText: String?,
        dailyValues: [Int]?
    ) -> String {
        let parts: [String] = [
            type.rawValue,
            title,
            subtitle ?? "",
            mainValue ?? "",
            completedValue ?? "",
            secondaryValue ?? "",
            medicationTaken ?? "",
            medicationMissed ?? "",
            detailText ?? "",
            (dailyValues ?? []).map(String.init).joined(separator: ",")
        ]
        return parts.joined(separator: "|")
    }

    func formatGraphValue(_ value: Int) -> String {
        switch type {
        case .hydration:
            if value < 1000 { return "\(value) ml" }
            let liters = Double(value) / 1000.0
            let formatter = NumberFormatter()
            formatter.minimumFractionDigits = 0
            formatter.maximumFractionDigits = 2
            let litersString = formatter.string(from: NSNumber(value: liters)) ?? "\(liters)"
            return "\(litersString) L"
        case .symptoms:
            return "severity : \(value)"
        default:
            return "\(value)"
        }
    }
}


struct HealthInsightResponse: Codable {
    let insights: [HealthInsight]

    static func loadFromFile() -> [HealthInsight] {
        guard let url = Bundle.main.url(forResource: "insights", withExtension: "json"),
              let data = try? Data(contentsOf: url) else { return [] }
        return (try? JSONDecoder().decode(HealthInsightResponse.self, from: data))?.insights ?? []
    }
}

// MARK: - Guided Reflection

struct GuidedReflectionQuestion: Identifiable, Codable {
    let id: UUID
    let category: ReflectionCategory
    let question: String
    let tags: [String]?
}

enum ReflectionCategory: String, Codable, CaseIterable {
    case mindfulness
    case gratitude
    case anxiety
    case positivity
    case healing
    case selfCompassion = "self_compassion"
}

// MARK: - Memory

struct Memory: Codable, Identifiable {
    let id: String
    let imageData: Data?
    let date: Date
    let note: String?

    init(
        id: String = UUID().uuidString,
        imageData: Data?,
        date: Date,
        note: String?
    ) {
        self.id = id
        self.imageData = imageData
        self.date = date
        self.note = note
    }
}

struct HydrationEntry: Codable, Identifiable {
    let id: UUID
    var amountML: Int
    var timestamp: Date

    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: timestamp)
    }

    init(id: UUID = UUID(), amountML: Int, timestamp: Date = Date()) {
        self.id = id
        self.amountML = amountML
        self.timestamp = timestamp
    }
}

// MARK: - Garden

struct StoreItem: Codable {
    let id: String
    let name: String
    let imageName: String
    let price: Int
    let category: String
}

struct PlacedItem: Codable {
    let id: String
    let imageName: String
    let positionX: CGFloat
    let positionY: CGFloat
    let zPosition: CGFloat
}
