//
//  AppointmentManager.swift
//  Appointments
//
//  Created by Naman Bhansali on 11/01/26.
//

import Foundation

class AppointmentManager {

    static let shared = AppointmentManager()

    private let userDefaults    = UserDefaults.standard
    private let appointmentsKey = "SavedAppointments"
    private var appointments: [String: [AppointmentItem]] = [:]

    private init() { loadAppointments() }

    func getDateKey(for date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }

    private func loadAppointments() {
        guard let data = userDefaults.data(forKey: appointmentsKey),
              let decoded = try? JSONDecoder().decode(
                  [String: [AppointmentItemCodable]].self, from: data)
        else { return }
        appointments = decoded.mapValues { $0.map { $0.toAppointmentItem() } }
    }

    private func saveAppointments() {
        let codable = appointments.mapValues { $0.map { AppointmentItemCodable(from: $0) } }
        if let encoded = try? JSONEncoder().encode(codable) {
            userDefaults.set(encoded, forKey: appointmentsKey)
        }
    }

    func saveAppointment(_ appointment: AppointmentItem, for date: Date) {
        let key = getDateKey(for: date)
        if var existing = appointments[key] {
            if let idx = existing.firstIndex(where: { $0.id == appointment.id }) {
                existing[idx] = appointment
            } else {
                existing.append(appointment)
            }
            appointments[key] = existing
        } else {
            appointments[key] = [appointment]
        }
        saveAppointments()
    }

    func getAppointments(for date: Date) -> [AppointmentItem] {
        appointments[getDateKey(for: date)] ?? []
    }

    func deleteAppointment(_ appointmentId: String, for date: Date) {
        let key = getDateKey(for: date)
        guard var existing = appointments[key] else { return }
        existing.removeAll { $0.id == appointmentId }
        if existing.isEmpty {
            appointments.removeValue(forKey: key)
        } else {
            appointments[key] = existing
        }
        saveAppointments()
    }

    func hasAppointments(for date: Date) -> Bool {
        !(appointments[getDateKey(for: date)]?.isEmpty ?? true)
    }

    func getAllDatesWithAppointments() -> [String] {
        Array(appointments.keys)
    }
}

// MARK: - Codable bridge
struct AppointmentItemCodable: Codable {
    let id: String
    let title: String
    let category: String
    let date: String
    let time: String
    let reminderEnabled: Bool
    let reminderOffsets: [String]           // ← NEW
    let note: String
    let colorIndex: Int

    init(from a: AppointmentItem) {
        id              = a.id
        title           = a.title
        category        = a.category
        date            = a.date
        time            = a.time
        reminderEnabled = a.reminderEnabled
        reminderOffsets = a.reminderOffsets.map { $0.rawValue }   // ← NEW
        note            = a.note
        colorIndex      = a.colorIndex
    }

    func toAppointmentItem() -> AppointmentItem {
        AppointmentItem(
            id:              id,
            title:           title,
            category:        category,
            date:            date,
            time:            time,
            reminderEnabled: reminderEnabled,
            reminderOffsets: reminderOffsets.compactMap { ReminderOffset(rawValue: $0) },  // ← NEW
            note:            note,
            colorIndex:      colorIndex
        )
    }
}
