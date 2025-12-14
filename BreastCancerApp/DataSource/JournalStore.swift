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


    // load
    func load() {
        self.entries = SampleJournalData.all
    }
    // add
    func add(_ entry: JournalEntry) {
        entries.insert(entry, at: 0)
    }
    // update
    func update(_ entry: JournalEntry) {
        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[index] = entry
        }
    }
    // delete
    func delete(_ entry: JournalEntry) {
        entries.removeAll(where: { $0.id == entry.id })
    }
}

extension Collection where Element == JournalEntry {

    // Normalize date to midnight (remove time)
    private func normalized(_ date: Date) -> Date {
        Calendar.current.startOfDay(for: date)
    }

    // streak calculation
    var streakCount: Int {
        guard count >= 2 else { return 0 }

        let calendar = Calendar.current
        let dates = Set(
            map { calendar.startOfDay(for: $0.date) }
        ).sorted(by: >)

        guard dates.count >= 2 else { return 0 }

        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        guard dates[0] == today || dates[0] == yesterday else {
            return 0
        }

        var streak = 1
        var prev = dates[0]

        for i in 1..<dates.count {
            let current = dates[i]
            if calendar.dateComponents([.day], from: current, to: prev).day == 1 {
                streak += 1
                prev = current
            } else {
                break
            }
        }

        // Enforce minimum streak length = 2
        return streak >= 2 ? streak : 0
    }

    // week's journal count
    var journalsThisWeek: Int {
        let calendar = Calendar.current
        let now = Date()
        guard let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)) else {
            return 0
        }

        return self.filter {
            calendar.isDate($0.date, equalTo: now, toGranularity: .weekOfYear)
        }.count

    }
    
    // All dates (normalized) where at least one journal exists
    var journalDays: Set<Date> {
        let calendar = Calendar.current
        return Set(
            self.map {
                calendar.startOfDay(for: $0.date)
            }
        )
    }

    // Journals for a specific day
    func journals(on date: Date) -> [JournalEntry] {
        let calendar = Calendar.current
        let target = calendar.startOfDay(for: date)
        return self.filter {
            calendar.startOfDay(for: $0.date) == target
        }
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


