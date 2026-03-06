import Foundation
import UserNotifications

final class AppointmentReminderScheduler {
    static let shared = AppointmentReminderScheduler()

    private let center = UNUserNotificationCenter.current()
    private let identifierPrefix = "appointment-reminder-"

    private init() {}

    func syncReminders(for appointments: [AppointmentItem], showPermissionAlert: Bool = true) {
        removeAllPendingReminders { [weak self] in
            guard let self else { return }

            let enabledAppointments = appointments.filter(\.reminderEnabled)
            guard !enabledAppointments.isEmpty else { return }

            self.requestAuthorizationIfNeeded(showPermissionAlert: showPermissionAlert) { granted in
                guard granted else { return }
                self.scheduleGroupedReminders(for: enabledAppointments)
            }
        }
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

    private func scheduleGroupedReminders(for appointments: [AppointmentItem]) {
        var grouped: [String: (date: Date, appointments: [AppointmentItem])] = [:]

        for appointment in appointments {
            for offset in appointment.reminderOffsets {
                guard let reminderDate = reminderDate(for: appointment, offset: offset),
                      reminderDate > Date()
                else { continue }

                let key = reminderTriggerKey(for: reminderDate)
                if grouped[key] == nil {
                    grouped[key] = (date: reminderDate, appointments: [appointment])
                } else {
                    grouped[key]?.appointments.append(appointment)
                }
            }
        }

        for (key, value) in grouped {
            let content = UNMutableNotificationContent()
            content.title = "Appointment Reminder"
            content.body = reminderBody(for: value.appointments)
            content.sound = .default

            let triggerDate = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: value.date
            )
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
            let request = UNNotificationRequest(
                identifier: notificationIdentifier(for: key),
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

    private func reminderBody(for appointments: [AppointmentItem]) -> String {
        if appointments.count == 1, let appointment = appointments.first {
            return "\(appointment.title) is on \(formattedAppointmentDateTime(for: appointment))."
        }

        let names = appointments.map(\.title)
        if names.count == 2 {
            return "You have 2 appointments coming up: \(names[0]) and \(names[1])."
        }

        let preview = names.prefix(3).joined(separator: ", ")
        let remaining = names.count - min(names.count, 3)
        return "You have \(names.count) appointments coming up: \(preview), and \(remaining) more."
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

    private func reminderTriggerKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HH-mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: date)
    }

    private func notificationIdentifier(for key: String) -> String {
        identifierPrefix + key
    }

    private func removeAllPendingReminders(completion: @escaping () -> Void) {
        center.getPendingNotificationRequests { [weak self] requests in
            guard let self else {
                completion()
                return
            }

            let identifiers = requests
                .map(\.identifier)
                .filter { $0.hasPrefix(self.identifierPrefix) }

            self.center.removePendingNotificationRequests(withIdentifiers: identifiers)
            completion()
        }
    }
}
