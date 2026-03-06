import Foundation

enum ReminderResyncService {
    static func syncAll() {
        syncMedicationRemindersForToday()
        syncFutureAppointmentReminders()
    }

    private static func syncMedicationRemindersForToday() {
        guard let entry = MedicationHistory.shared.getHistory(for: Date()) else { return }

        for medication in entry.medications where medication.reminderEnabled {
            MedicationReminderScheduler.shared.syncReminder(for: medication, showPermissionAlert: false)
        }
    }

    private static func syncFutureAppointmentReminders() {
        let now = Date()
        let keyFormatter = DateFormatter()
        keyFormatter.dateFormat = "yyyy-MM-dd"

        let appointmentFormatter = DateFormatter()
        appointmentFormatter.dateFormat = "dd MMM yyyy h:mm a"
        appointmentFormatter.locale = Locale(identifier: "en_US_POSIX")

        for key in AppointmentManager.shared.getAllDatesWithAppointments() {
            guard let date = keyFormatter.date(from: key) else { continue }

            for appointment in AppointmentManager.shared.getAppointments(for: date) where appointment.reminderEnabled {
                guard let appointmentDate = appointmentFormatter.date(from: "\(appointment.date) \(appointment.time)"),
                      appointmentDate > now
                else { continue }

                AppointmentReminderScheduler.shared.syncReminders(for: appointment, showPermissionAlert: false)
            }
        }
    }
}
