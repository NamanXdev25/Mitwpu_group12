//
//  BreathingFavoritesManager.swift
//  BreastCancerApp
//
//  Created by Shloka on 16/12/25.
//
import Foundation

struct BreathingFavoritesManager {

    static func toggleFavorite(
        session: BreathingSession,
        allSessions: inout [BreathingSession],
        favorites: inout [BreathingSession],
        filtered: inout [BreathingSession]
    ) {
        var updatedSession = session
        updatedSession.isFavorite.toggle()

        // Update master list
        if let index = allSessions.firstIndex(where: { $0.title == session.title }) {
            allSessions[index] = updatedSession
        }

        // Update filtered list
        if let index = filtered.firstIndex(where: { $0.title == session.title }) {
            filtered[index] = updatedSession
        }

        // Update favorites list
        if updatedSession.isFavorite {
            favorites.insert(updatedSession, at: 0)
        } else {
            favorites.removeAll { $0.title == updatedSession.title }
        }
    }
}

