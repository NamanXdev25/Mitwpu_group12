import Foundation

enum BreathingFavoritesManager {
    static func toggleFavorite(
        session: BreathingSession,
        allSessions: inout [BreathingSession],
        favorites: inout [BreathingSession],
        filtered: inout [BreathingSession]
    ) {
        var updatedSession = session
        updatedSession.isFavorite.toggle()

        if let index = allSessions.firstIndex(where: { $0.title == session.title }) {
            allSessions[index] = updatedSession
        }

        if let index = filtered.firstIndex(where: { $0.title == session.title }) {
            filtered[index] = updatedSession
        }

        if updatedSession.isFavorite {
            favorites.insert(updatedSession, at: 0)
        } else {
            favorites.removeAll { $0.title == updatedSession.title }
        }
    }
}
