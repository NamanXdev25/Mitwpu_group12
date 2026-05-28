import Foundation

final class DailyQuoteLoader {
    static let shared = DailyQuoteLoader()
    private init() {}

    private struct QuoteFile: Decodable {
        let affirmations: [QuoteEntry]
    }

    private struct QuoteEntry: Decodable {
        let day: Int
        let text: String
    }

    private let kShuffledQueue = "dailyQuote_shuffledQueue"
    private let kCurrentIndex = "dailyQuote_currentIndex"
    private let kLastShownDate = "dailyQuote_lastShownDate"

    private var cachedQuote: String?
    private var cachedDate: String?

    func todayQuote() -> String {
        let today = dateString(from: Date())

        if cachedDate == today, let q = cachedQuote {
            return q
        }

        let quote = resolveQuote(for: today)
        cachedDate = today
        cachedQuote = quote
        return quote
    }

    private func resolveQuote(for today: String) -> String {
        let defaults = UserDefaults.standard

        var queue: [String] = defaults.stringArray(forKey: kShuffledQueue) ?? []
        var index: Int = defaults.integer(forKey: kCurrentIndex)
        let lastDate: String = defaults.string(forKey: kLastShownDate) ?? ""

        if queue.isEmpty {
            queue = buildShuffledQueue()
            index = 0
            defaults.set(queue, forKey: kShuffledQueue)
            defaults.set(index, forKey: kCurrentIndex)
            defaults.set(today, forKey: kLastShownDate)
            return queue.first ?? fallback
        }

        if lastDate == today {
            guard index < queue.count else { return fallback }
            return queue[index]
        }

        index += 1

        if index >= queue.count {
            queue = buildShuffledQueue()
            index = 0
            defaults.set(queue, forKey: kShuffledQueue)
        }

        defaults.set(index, forKey: kCurrentIndex)
        defaults.set(today, forKey: kLastShownDate)

        guard index < queue.count else { return fallback }
        return queue[index]
    }

    private func buildShuffledQueue() -> [String] {
        guard let texts = loadAllTexts(), !texts.isEmpty else { return [fallback] }
        return texts.shuffled()
    }

    private func loadAllTexts() -> [String]? {
        guard
            let url = Bundle.main.url(forResource: "quotes", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let file = try? JSONDecoder().decode(QuoteFile.self, from: data)
        else { return nil }
        return file.affirmations.map { $0.text }
    }

    private func dateString(from date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }

    private let fallback = "You are stronger than you know."
}
