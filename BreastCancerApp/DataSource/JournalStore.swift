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
        do {
            let data = try Data(contentsOf: fileURL)
            let decoded = try JSONDecoder().decode([JournalEntry].self, from: data)
            self.entries = decoded
        } catch {
            print("No saved file yet or failed to load → starting fresh.")
            self.entries = []
        }
    }

    // MARK: - SAVE
    func save() {
        do {
            let data = try JSONEncoder().encode(entries)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            print("Error saving journals: \(error)")
        }
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
