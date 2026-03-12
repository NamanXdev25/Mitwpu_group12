import Foundation

struct BreathingSessionFilter {

    static func apply(
        sessions: [BreathingSession],
        category: String
    ) -> [BreathingSession] {

        guard category != "All" else {
            return sessions
        }

        return sessions.filter { session in
            session.category == category
        }
    }
}
