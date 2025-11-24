//
//  SampleJournalData.swift
//  journalTrial
//
//  Created by Shivani Dinesh on 24/11/25.
//

import Foundation
import UIKit

enum SampleJournalData {
    static let recent: [JournalEntry] = [
        JournalEntry(
            title: "Finding Calm Before Chemo",
            body: "Had my chemo session today. Practiced deep breathing before leaving...",
            date: Date().addingTimeInterval(-86400)
        ),
        JournalEntry(
            title: "A Quiet Morning",
            body: "Felt more energy today. Sat in the garden and recorded some thoughts...",
            date: Date().addingTimeInterval(-86400 * 3)
        ),
        JournalEntry(
            title: "Small Wins",
            body: "Managed to cook and enjoy a small meal without nausea.",
            date: Date().addingTimeInterval(-86400 * 6)
        )
    ]
}
