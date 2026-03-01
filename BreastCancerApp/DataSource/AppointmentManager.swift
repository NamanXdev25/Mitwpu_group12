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
    
    private var appointments: [String: [AppointmentItem]] = [:]
    
    private init() {
        loadAppointments()
    }
    
    func getDateKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    private func loadAppointments() {
        guard let data = userDefaults.data(forKey: appointmentsKey),
              let decoded = try? JSONDecoder().decode([String: [AppointmentItemCodable]].self, from: data) else {
            return
        }
        
        appointments = decoded.mapValues { codableItems in
            codableItems.map { $0.toAppointmentItem() }
        }
    }
    
    private func saveAppointments() {
        let codableAppointments = appointments.mapValues { items in
            items.map { AppointmentItemCodable(from: $0) }
        }
        
        if let encoded = try? JSONEncoder().encode(codableAppointments) {
            userDefaults.set(encoded, forKey: appointmentsKey)
        }
    }
    
    func saveAppointment(_ appointment: AppointmentItem, for date: Date) {
        let key = getDateKey(for: date)
        
        if var existing = appointments[key] {
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
    
    func getAppointments(for date: Date) -> [AppointmentItem] {
        let key = getDateKey(for: date)
        return appointments[key] ?? []
    }
    
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
    
    func hasAppointments(for date: Date) -> Bool {
        let key = getDateKey(for: date)
        return appointments[key] != nil && !appointments[key]!.isEmpty
    }
    
    func getAllDatesWithAppointments() -> [String] {
        return Array(appointments.keys)
    }
}
