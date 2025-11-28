//
//  JournalStore.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 28/11/25.
//

import Foundation

class JournalStore {

    static let shared = JournalStore()

    private init() {
        load()
    }

    private(set) var entries: [JournalEntry] = []


    // MARK: - LOAD
    func load() {
        self.entries = SampleJournalData.all
    }

    // MARK: - ADD
    func add(_ entry: JournalEntry) {
        entries.insert(entry, at: 0)
    }

    // MARK: - UPDATE
    func update(_ entry: JournalEntry) {
        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[index] = entry
        }
    }

    // MARK: - DELETE
    func delete(_ entry: JournalEntry) {
        entries.removeAll(where: { $0.id == entry.id })
    }
}


extension Collection where Element == JournalEntry {

    // Normalize date to midnight (remove time)
    private func normalized(_ date: Date) -> Date {
        Calendar.current.startOfDay(for: date)
    }

    // MARK: - Streak Calculation
    var streakCount: Int {
        guard !self.isEmpty else { return 0 }

        // Get all unique days the user journaled
        let dates = self
            .map { Calendar.current.startOfDay(for: $0.date) }
            .sorted(by: >)

        var streak = 1
        var prev = dates[0]

        for i in 1..<dates.count {
            let current = dates[i]
            // If the next day is exactly 1 day apart → streak continues
            if let diff = Calendar.current.dateComponents([.day], from: current, to: prev).day,
               diff == 1 {
                streak += 1
                prev = current
            } else {
                break
            }
        }

        return streak
    }

    // MARK: - Journals This Week
    var journalsThisWeek: Int {
        let calendar = Calendar.current
        let now = Date()
        guard let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)) else {
            return 0
        }

        return self.filter {
            $0.date >= weekStart
        }.count
    }
}

extension Array where Element == JournalEntry {
    func todayGuidedEntry() -> JournalEntry? {
        let calendar = Calendar.current
        return self.first {
            $0.type == .guided && calendar.isDateInToday($0.date)
        }
    }
}

