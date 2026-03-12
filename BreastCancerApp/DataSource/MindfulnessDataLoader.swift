
import Foundation

class MindfulnessDataLoader {
    static let shared = MindfulnessDataLoader()
    private(set) var root: MindfulnessJSONRoot?

    private init() {
        load()
    }

    private func load() {
        guard let url = Bundle.main.url(forResource: "moodSuggestion", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            return
        }

        do {
            let dec = JSONDecoder()
            root = try dec.decode(MindfulnessJSONRoot.self, from: data)
        } catch {
        }
    }

    func moodContent(for moodKey: String) -> MoodContent? {
        return root?.moods[moodKey]
    }
}
