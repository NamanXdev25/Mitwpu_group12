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

    private let fileName = "journals.json"

    private(set) var entries: [JournalEntry] = []

    // MARK: - File URL
    private var fileURL: URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documents.appendingPathComponent(fileName)
    }

    // MARK: - LOAD
    
    func load() {
        // Always start fresh with sample data
        self.entries = SampleJournalData.all
    }
    
    // LOAD WITH PERSISTENCE
    /*
    func load() {
        do {
            let data = try Data(contentsOf: fileURL)
            let decoded = try JSONDecoder().decode([JournalEntry].self, from: data)
            self.entries = decoded
        } catch {
            print("No saved file yet → loading sample data")
            self.entries = SampleJournalData.all
            save()
        }
    }
     */

    // MARK: - SAVE
    func save() {
        
        // SAVE FOR PERSISTANCE
        /*
        do {
            let data = try JSONEncoder().encode(entries)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            print("Error saving journals: \(error)")
        }
         */
    }

    // MARK: - ADD
    func add(_ entry: JournalEntry) {
        entries.insert(entry, at: 0)
        save()
    }

    // MARK: - UPDATE
    func update(_ entry: JournalEntry) {
        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[index] = entry
            save()
        }
    }

    // MARK: - DELETE
    func delete(_ entry: JournalEntry) {
        entries.removeAll(where: { $0.id == entry.id })
        save()
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

