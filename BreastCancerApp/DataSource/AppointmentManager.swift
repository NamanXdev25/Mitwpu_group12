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

    init(repository: AppointmentRepository = FirestoreAppointmentRepository()) {
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
        AppointmentReminderScheduler.shared.syncReminders(for: getAllAppointments())
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

        persist()
        AppointmentReminderScheduler.shared.syncReminders(for: getAllAppointments(), showPermissionAlert: false)
    }

    func hasAppointments(for date: Date) -> Bool {
        !(appointments[getDateKey(for: date)]?.isEmpty ?? true)
    }

    func getAllDatesWithAppointments() -> [String] {
        Array(appointments.keys)
    }

    func getAllAppointments() -> [AppointmentItem] {
        appointments.values.flatMap { $0 }
    }
}
