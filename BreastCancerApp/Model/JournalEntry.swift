//
//  JournalEntry.swift
//  journalTrial
//
//  Created by Shivani Dinesh on 24/11/25.
//

import Foundation
import UIKit

enum JournalType: String, Codable {
    case regular
    case guided
}

struct JournalEntry: Hashable, Identifiable, Codable {
    let id: UUID
    var title: String
    var body: String
    var date: Date
    var type: JournalType
    var question: String?
    var category: String?
    
    init(
        id: UUID = UUID(),
        title: String,
        body: String,
        date: Date = Date(),
        type: JournalType,
        question: String? = nil,
        category: String? = nil
    ) {
        self.id = id
        self.title = title
        self.body = body
        self.date = date
        self.type = type
        self.question = question
        self.category = category
    }
}

extension JournalEntry {
    var content: String {
        return body
    }

    var dateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    var formattedDateTitle: String {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")

        let thisYear = calendar.component(.year, from: Date())
        let entryYear = calendar.component(.year, from: date)

        if thisYear == entryYear {
            formatter.setLocalizedDateFormatFromTemplate("EEE, MMM d")
        } else {
            formatter.setLocalizedDateFormatFromTemplate("MMM d, yyyy")
        }
        return formatter.string(from: date)
    }
}
