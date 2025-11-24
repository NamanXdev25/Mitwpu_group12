//
//  JournalEntry.swift
//  journalTrial
//
//  Created by Shivani Dinesh on 24/11/25.
//

import Foundation
import UIKit

struct JournalEntry: Hashable, Identifiable {
    let id: UUID
    var title: String
    var body: String
    var date: Date
    var mood: String?
    var thumbnail: UIImage?

    init(
        id: UUID = UUID(),
        title: String,
        body: String,
        date: Date = Date(),
        mood: String? = nil,
        thumbnail: UIImage? = nil
    ) {
        self.id = id
        self.title = title
        self.body = body
        self.date = date
        self.mood = mood
        self.thumbnail = thumbnail
    }
}
