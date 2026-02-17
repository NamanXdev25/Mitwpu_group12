import Foundation

enum InsightType: String, Codable {
    case hydration, exercise, medication, symptoms
}

struct HealthInsight: Codable, Identifiable {
    let id: UUID
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
        case type, title, subtitle, mainValue, completedValue, secondaryValue,
             medicationTaken, medicationMissed, detailText, dailyValues
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.type = try container.decode(InsightType.self, forKey: .type)
        self.title = try container.decode(String.self, forKey: .title)
        self.subtitle = try container.decodeIfPresent(String.self, forKey: .subtitle)
        self.mainValue = try container.decodeIfPresent(String.self, forKey: .mainValue)
        self.completedValue = try container.decodeIfPresent(String.self, forKey: .completedValue)
        self.secondaryValue = try container.decodeIfPresent(String.self, forKey: .secondaryValue)
        self.medicationTaken = try container.decodeIfPresent(String.self, forKey: .medicationTaken)
        self.medicationMissed = try container.decodeIfPresent(String.self, forKey: .medicationMissed)
        self.detailText = try container.decodeIfPresent(String.self, forKey: .detailText)
        self.dailyValues = try container.decodeIfPresent([Int].self, forKey: .dailyValues)
    }

    func formatGraphValue(_ value: Int) -> String {
        switch type {
        case .hydration:
            if value < 1000 {
                return "\(value) ml"
            } else {
                let liters = Double(value) / 1000.0
                let formatter = NumberFormatter()
                formatter.minimumFractionDigits = 0
                formatter.maximumFractionDigits = 2
                let litersString = formatter.string(from: NSNumber(value: liters)) ?? "\(liters)"
                return "\(litersString) L"
            }
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
