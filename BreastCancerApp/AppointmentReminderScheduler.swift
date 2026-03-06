import Foundation
import UserNotifications

final class AppointmentReminderScheduler {
    static let shared = AppointmentReminderScheduler()

    private let center = UNUserNotificationCenter.current()
    private let identifierPrefix = "appointment-reminder-"

    private init() {}

    func syncReminders(for appointment: AppointmentItem, showPermissionAlert: Bool = true) {
        let identifiers = notificationIdentifiers(for: appointment.id)
        center.removePendingNotificationRequests(withIdentifiers: identifiers)

        guard appointment.reminderEnabled else { return }

        requestAuthorizationIfNeeded(showPermissionAlert: showPermissionAlert) { [weak self] granted in
            guard granted else { return }
            self?.scheduleReminders(for: appointment)
        }
    }

    func removeReminders(for appointmentID: String) {
        center.removePendingNotificationRequests(
            withIdentifiers: notificationIdentifiers(for: appointmentID)
        )
    }

    private func requestAuthorizationIfNeeded(
        showPermissionAlert: Bool,
        completion: @escaping (Bool) -> Void
    ) {
        center.getNotificationSettings { [weak self] settings in
            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral:
                completion(true)
            case .notDetermined:
                self?.center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                    if !granted, showPermissionAlert {
                        NotificationPermissionAlertPresenter.show(
                            title: "Notifications Disabled",
                            message: "Enable notifications in Settings to receive appointment reminders."
                        )
                    }
                    completion(granted)
                }
            case .denied:
                if showPermissionAlert {
                    NotificationPermissionAlertPresenter.show(
                        title: "Notifications Disabled",
                        message: "Enable notifications in Settings to receive appointment reminders."
                    )
                }
                completion(false)
            @unknown default:
                completion(false)
            }
        }
    }

    private func scheduleReminders(for appointment: AppointmentItem) {
        for offset in appointment.reminderOffsets {
            guard let reminderDate = reminderDate(for: appointment, offset: offset),
                  reminderDate > Date()
            else { continue }

            let content = UNMutableNotificationContent()
            content.title = "Appointment Reminder"
            content.body = reminderBody(for: appointment, offset: offset)
            content.sound = .default

            let triggerDate = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: reminderDate
            )
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
            let request = UNNotificationRequest(
                identifier: notificationIdentifier(for: appointment.id, offset: offset),
                content: content,
                trigger: trigger
            )

            center.add(request)
        }
    }

    private func reminderDate(for appointment: AppointmentItem, offset: ReminderOffset) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy h:mm a"
        formatter.locale = Locale(identifier: "en_US_POSIX")

        guard let appointmentDate = formatter.date(from: "\(appointment.date) \(appointment.time)") else {
            return nil
        }

        let minutesOffset: Int
        switch offset {
        case .atTime:
            minutesOffset = 0
        case .min15:
            minutesOffset = 15
        case .min30:
            minutesOffset = 30
        case .hour1:
            minutesOffset = 60
        case .hour2:
            minutesOffset = 120
        case .day1:
            minutesOffset = 24 * 60
        case .day2:
            minutesOffset = 48 * 60
        }

        return Calendar.current.date(byAdding: .minute, value: -minutesOffset, to: appointmentDate)
    }

    private func reminderBody(for appointment: AppointmentItem, offset: ReminderOffset) -> String {
        let appointmentDateText = formattedAppointmentDateTime(for: appointment)

        if offset == .atTime {
            return "\(appointment.title) is scheduled for \(appointmentDateText)."
        }
        return "\(appointment.title) is on \(appointmentDateText)."
    }

    private func formattedAppointmentDateTime(for appointment: AppointmentItem) -> String {
        let parser = DateFormatter()
        parser.dateFormat = "dd MMM yyyy h:mm a"
        parser.locale = Locale(identifier: "en_US_POSIX")

        guard let appointmentDate = parser.date(from: "\(appointment.date) \(appointment.time)") else {
            return "\(appointment.date) at \(appointment.time)"
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy 'at' h:mm a"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: appointmentDate)
    }

    private func notificationIdentifiers(for appointmentID: String) -> [String] {
        ReminderOffset.allCases.map { notificationIdentifier(for: appointmentID, offset: $0) }
    }

    private func notificationIdentifier(for appointmentID: String, offset: ReminderOffset) -> String {
        let safeOffset = offset.rawValue.replacingOccurrences(of: " ", with: "-").lowercased()
        return "\(identifierPrefix)\(appointmentID)-\(safeOffset)"
    }
}
