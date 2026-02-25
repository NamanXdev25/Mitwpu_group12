import Foundation

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
    let description: String
    let image: String?
}

final class HomeMoodSuggestionLoader {
    static let shared = HomeMoodSuggestionLoader()
    private(set) var root: HomeMoodSuggestionRoot?

    private init() { load() }

    private func load() {
        guard let url = Bundle.main.url(forResource: "moodSuggestion", withExtension: "json"),
              let rawData = try? Data(contentsOf: url),
              let rawText = String(data: rawData, encoding: .utf8) else {
            print("Home moodSuggestion.json not found")
            return
        }

        // File contains many // commented lines. Remove them before decoding.
        let cleaned = rawText.replacingOccurrences(
            of: #"(?m)^\s*//.*\n?"#,
            with: "",
            options: .regularExpression
        )

        guard let data = cleaned.data(using: .utf8) else { return }

        do {
            root = try JSONDecoder().decode(HomeMoodSuggestionRoot.self, from: data)
        } catch {
            print("Home moodSuggestion decode error:", error)
        }
    }

    func moodContent(for key: String) -> HomeMoodSuggestionContent? {
        root?.moods[key.lowercased()]
    }
}
