import Foundation

final class HomeMoodSuggestionLoader {
    static let shared = HomeMoodSuggestionLoader()
    private(set) var root: HomeMoodSuggestionRoot?

    private init() {
        load()
    }

    private func load() {
        guard let url = Bundle.main.url(forResource: "moodSuggestion", withExtension: "json"),
              let rawData = try? Data(contentsOf: url),
              let rawText = String(data: rawData, encoding: .utf8)
        else {
            return
        }

        let cleaned = rawText.replacingOccurrences(
            of: #"(?m)^\s*//.*\n?"#,
            with: "",
            options: .regularExpression
        )

        guard let data = cleaned.data(using: .utf8) else { return }

        do {
            root = try JSONDecoder().decode(HomeMoodSuggestionRoot.self, from: data)
        } catch {}
    }

    func moodContent(for key: String) -> HomeMoodSuggestionContent? {
        root?.moods[key.lowercased()]
    }
}
