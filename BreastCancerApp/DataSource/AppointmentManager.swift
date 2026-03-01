//
//  AppointmentManager.swift
//  Appointments
//
//  Created by Naman Bhansali on 11/01/26.
//

import Foundation

class AppointmentManager {
    static let shared = AppointmentManager()

    private let repository: AppointmentRepository
    private var appointments: [String: [AppointmentItem]]

    init(repository: AppointmentRepository = UserDefaultsAppointmentRepository()) {
        self.repository = repository
        self.appointments = repository.loadAppointments()
    }

    func getDateKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    private func persist() {
        repository.saveAppointments(appointments)
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

        persist()
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

            persist()
        }
    }

    func hasAppointments(for date: Date) -> Bool {
        let key = getDateKey(for: date)
        return appointments[key]?.isEmpty == false
    }

    func getAllDatesWithAppointments() -> [String] {
        Array(appointments.keys)
    }
}
