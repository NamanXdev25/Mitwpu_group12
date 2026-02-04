import Foundation

// 1. Define the types of cards available in the dashboard
enum InsightType: String, Codable {
    case hydration, exercise, medication, symptoms, mood
}

// 2. The main data model for each card
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
    let dailyValues: [Int]?   // For the line graphs (Hydration/Symptoms)
    let moodValues: [String]? // For the Mood Garden flower grid

    // 3. Keys that match your insights.json file exactly
    enum CodingKeys: String, CodingKey {
        case type, title, subtitle, mainValue, completedValue, secondaryValue,
             medicationTaken, medicationMissed, detailText, dailyValues, moodValues
    }

    // 4. Custom initializer for JSON decoding
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Always generate a fresh UUID for the Identifiable protocol
        self.id = UUID()
        
        // Required properties
        self.type = try container.decode(InsightType.self, forKey: .type)
        self.title = try container.decode(String.self, forKey: .title)
        
        // Optional properties (use decodeIfPresent to avoid crashes if keys are missing)
        self.subtitle = try container.decodeIfPresent(String.self, forKey: .subtitle)
        self.mainValue = try container.decodeIfPresent(String.self, forKey: .mainValue)
        self.completedValue = try container.decodeIfPresent(String.self, forKey: .completedValue)
        self.secondaryValue = try container.decodeIfPresent(String.self, forKey: .secondaryValue)
        self.medicationTaken = try container.decodeIfPresent(String.self, forKey: .medicationTaken)
        self.medicationMissed = try container.decodeIfPresent(String.self, forKey: .medicationMissed)
        self.detailText = try container.decodeIfPresent(String.self, forKey: .detailText)
        self.dailyValues = try container.decodeIfPresent([Int].self, forKey: .dailyValues)
        self.moodValues = try container.decodeIfPresent([String].self, forKey: .moodValues)
    }
}

// 5. Wrapper for the root of the JSON file
struct HealthInsightResponse: Codable {
    let insights: [HealthInsight]
    
    /// Loads data from 'insights.json' in the app bundle
    static func loadFromFile() -> [HealthInsight] {
        guard let url = Bundle.main.url(forResource: "insights", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("Error: Could not find insights.json")
            return []
        }
        
        do {
            let response = try JSONDecoder().decode(HealthInsightResponse.self, from: data)
            return response.insights
        } catch {
            print("Decoding error: \(error)")
            return []
        }
    }
}
