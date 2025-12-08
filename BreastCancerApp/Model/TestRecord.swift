//
//  TestRecord.swift
//  BreastCancerApp
//
//  Created by Gayatri Goundadkar on 08/12/25.
//

import Foundation

struct TestRecord: Codable {
  let id: UUID
  let date: Date
  let lumps: Bool
  let skinChanges: String?
  let nippleChanges: String?
  let sizeChange: Bool
  let pain: String?
}

extension UserDefaults {
  private static let key = "testRecords.v1"
  static func loadTestRecords() -> [TestRecord] {
    guard let d = standard.data(forKey: key) else { return [] }
    return (try? JSONDecoder().decode([TestRecord].self, from: d)) ?? []
  }
  static func saveTestRecords(_ r:[TestRecord]) {
    let d = try? JSONEncoder().encode(r); standard.set(d, forKey: key)
  }
}

