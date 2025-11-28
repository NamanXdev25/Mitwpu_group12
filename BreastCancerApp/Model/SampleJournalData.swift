//
//  SampleJournalData.swift
//  journalTrial
//
//  Created by Shivani Dinesh on 24/11/25.
//

import Foundation
import UIKit

enum SampleJournalData {
    static var recent: [JournalEntry] {
        Array(all.sorted(by: { $0.date > $1.date }).prefix(3))
    }
    
    static let all: [JournalEntry] = [
        JournalEntry(
            title: "Finding Calm Before Chemo",
            body: "Had my chemo session today. Practiced deep breathing before leaving...",
            date: Date().addingTimeInterval(-86400),
            type: .regular
        ),
        JournalEntry(
            title: "A Quiet Morning",
            body: "Felt more energy today. Sat in the garden and recorded some thoughts...",
            date: Date().addingTimeInterval(-86400 * 3),
            type: .regular
        ),
        JournalEntry(
            title: "Small Wins",
            body: "Managed to cook and enjoy a small meal without nausea.",
            date: Date().addingTimeInterval(-86400 * 6),
            type: .regular
        ),
        JournalEntry(
            title: "Reflecting on the Past",
            body: "Feeling grateful for the little things in life.",
            date: Date().addingTimeInterval(-86400 * 9),
            type: .regular
        ),
        JournalEntry(
            title: "Embracing Change",
            body: "Looking forward to new adventures and challenges.",
            date: Date().addingTimeInterval(-86400 * 12),
            type: .regular
        ),
        JournalEntry(
            title: "Hope in the Darkness",
            body: "Holding on to hope and positivity in the face of adversity.",
            date: Date().addingTimeInterval(-86400 * 15),
            type: .regular
        ),
        JournalEntry(
            title: "Gratitude Journal",
            body: "Listing out things I'm thankful for each day.",
            date: Date().addingTimeInterval(-86400 * 18),
            type: .regular
        ),
        JournalEntry(
            title: "Learning and Growing",
            body: "Always open to learning new things and growing as a person.",
            date: Date().addingTimeInterval(-86400 * 21),
            type: .regular
        ),
        JournalEntry(
            title: "Connecting with Loved Ones",
            body: "Striving to maintain and nurture relationships with family and friends.",
            date: Date().addingTimeInterval(-86400 * 24),
            type: .regular
        ),
        JournalEntry(
            title: "Living in the Moment",
            body: "Practicing mindfulness and living in the moment.",
            date: Date().addingTimeInterval(-86400 * 27),
            type: .regular
        )
    ]
}
