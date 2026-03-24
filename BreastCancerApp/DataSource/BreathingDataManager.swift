class BreathingDataManager {
    private let repository: BreathingRepository

    init(repository: BreathingRepository = RepositoryFactory.makeBreathingRepository()) {
        self.repository = repository
    }

    func getFavoriteSessions() -> [BreathingSession] {
        let favoritesOrder = repository.loadFavoriteTitles()
        let favoriteOrderIndex = Dictionary(uniqueKeysWithValues: favoritesOrder.enumerated().map { ($0.element, $0.offset) })
        return getAllSessions()
            .filter { $0.isFavorite }
            .sorted { favoriteOrderIndex[$0.title, default: .max] < favoriteOrderIndex[$1.title, default: .max] }
    }

    func getFilterTags() -> [String] {
        ["All", "Meditation", "Stress Relief", "Sleep", "Wellness", "Gratitude"]
    }

    func getAllSessions() -> [BreathingSession] {
        let favoriteTitles = repository.loadFavoriteTitles()
        let favorites = Set(favoriteTitles)

        var sessions = [
            BreathingSession(title: "Gentle Focus", category: "Meditation", duration: "15 min", imageName: "gentle_focus", isFavorite: false, videoFileName: "Gentle"),
            BreathingSession(title: "Healing Reflections", category: "Gratitude", duration: "10 min", imageName: "healing_reflections", isFavorite: false, videoFileName: "healing_video"),
            BreathingSession(title: "Calmer Mind", category: "Stress Relief", duration: "10 min", imageName: "calmer_mind", isFavorite: false, videoFileName: "calm_video"),
            BreathingSession(title: "Inner Calm", category: "Meditation", duration: "8 min", imageName: "inner_calm", isFavorite: false, videoFileName: "inner_video"),
            BreathingSession(title: "Gentle Recharge", category: "Stress Relief", duration: "13 min", imageName: "gentle_recharge", isFavorite: false, videoFileName: "recharge_video"),
            BreathingSession(title: "Nausea Relief", category: "Wellness", duration: "7 min", imageName: "nausea_relief", isFavorite: false, videoFileName: "nausea_video"),
            BreathingSession(title: "Morning Appreciation", category: "Gratitude", duration: "5 min", imageName: "morning_appreciation", isFavorite: false, videoFileName: "morning_video"),
            BreathingSession(title: "Deep Rest", category: "Sleep", duration: "16 min", imageName: "deep_rest", isFavorite: false, videoFileName: "sleep_video")
        ]

        for i in sessions.indices {
            sessions[i].isFavorite = favorites.contains(sessions[i].title)
        }

        return sessions
    }

    func saveFavoriteTitles(_ titles: [String]) {
        repository.saveFavoriteTitles(titles)
    }
}
