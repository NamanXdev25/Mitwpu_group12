//
//  AppointmentManager.swift
//  Appointments
//
//  Created by Naman Bhansali on 11/01/26.
//

import Foundation

class AppointmentManager {
    
    static let shared = AppointmentManager()
    
    private let userDefaults = UserDefaults.standard
    private let appointmentsKey = "SavedAppointments"
    
    // Dictionary: "yyyy-MM-dd" -> [AppointmentItem]
    private var appointments: [String: [AppointmentItem]] = [:]
    
    private init() {
        loadAppointments()
    }
    
    // MARK: - Date Key Helper
    func getDateKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    // MARK: - Load from UserDefaults
    private func loadAppointments() {
        guard let data = userDefaults.data(forKey: appointmentsKey),
              let decoded = try? JSONDecoder().decode([String: [AppointmentItemCodable]].self, from: data) else {
            return
        }
        
        // Convert codable to regular AppointmentItem
        appointments = decoded.mapValues { codableItems in
            codableItems.map { $0.toAppointmentItem() }
        }
    }
    
    // MARK: - Save to UserDefaults
    private func saveAppointments() {
        // Convert to codable version
        let codableAppointments = appointments.mapValues { items in
            items.map { AppointmentItemCodable(from: $0) }
        }
        
        if let encoded = try? JSONEncoder().encode(codableAppointments) {
            userDefaults.set(encoded, forKey: appointmentsKey)
        }
    }
    
    // MARK: - Public Methods
    
    /// Save or update an appointment
    func saveAppointment(_ appointment: AppointmentItem, for date: Date) {
        let key = getDateKey(for: date)
        
        if var existing = appointments[key] {
            // Check if updating existing appointment
            if let index = existing.firstIndex(where: { $0.id == appointment.id }) {
                existing[index] = appointment
            } else {
                existing.append(appointment)
            }
            appointments[key] = existing
        } else {
            appointments[key] = [appointment]
        }
        
        saveAppointments()
    }
    
    /// Get all appointments for a specific date
    func getAppointments(for date: Date) -> [AppointmentItem] {
        let key = getDateKey(for: date)
        return appointments[key] ?? []
    }
    
    /// Delete an appointment
    func deleteAppointment(_ appointmentId: String, for date: Date) {
        let key = getDateKey(for: date)
        
        if var existing = appointments[key] {
            existing.removeAll { $0.id == appointmentId }
            
            if existing.isEmpty {
                appointments.removeValue(forKey: key)
            } else {
                appointments[key] = existing
            }
            
            saveAppointments()
        }
    }
    
    /// Check if a date has any appointments
    func hasAppointments(for date: Date) -> Bool {
        let key = getDateKey(for: date)
        return appointments[key] != nil && !appointments[key]!.isEmpty
    }
    
    /// Get all dates that have appointments
    func getAllDatesWithAppointments() -> [String] {
        return Array(appointments.keys)
    }
}

// MARK: - Codable Version for UserDefaults
struct AppointmentItemCodable: Codable {
    let id: String
    let title: String
    let date: String
    let time: String
    let reminderEnabled: Bool
    let note: String
    let colorIndex: Int
    
    init(from appointment: AppointmentItem) {
        self.id = appointment.id
        self.title = appointment.title
        self.date = appointment.date
        self.time = appointment.time
        self.reminderEnabled = appointment.reminderEnabled
        self.note = appointment.note
        self.colorIndex = appointment.colorIndex
    }
    
    func toAppointmentItem() -> AppointmentItem {
        return AppointmentItem(
            id: id,
            title: title,
            date: date,
            time: time,
            reminderEnabled: reminderEnabled,
            note: note,
            colorIndex: colorIndex
        )
    }
}

