import Foundation
import UserNotifications

final class MedicationReminderScheduler {
    static let shared = MedicationReminderScheduler()

    private let center = UNUserNotificationCenter.current()
    private let identifierPrefix = "medication-reminder-"

    private init() {}

    func syncReminder(for medication: Medication, showPermissionAlert: Bool = true) {
        let identifier = notificationIdentifier(for: medication.id)

        center.removePendingNotificationRequests(withIdentifiers: [identifier])

        guard medication.reminderEnabled else { return }

        requestAuthorizationIfNeeded(showPermissionAlert: showPermissionAlert) { [weak self] granted in
            guard granted else { return }
            self?.scheduleReminder(for: medication, identifier: identifier)
        }
    }

    func removeReminder(for medicationID: String) {
        center.removePendingNotificationRequests(
            withIdentifiers: [notificationIdentifier(for: medicationID)]
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
                            message: "Enable notifications in Settings to receive medication reminders."
                        )
                    }
                    completion(granted)
                }
            case .denied:
                if showPermissionAlert {
                    NotificationPermissionAlertPresenter.show(
                        title: "Notifications Disabled",
                        message: "Enable notifications in Settings to receive medication reminders."
                    )
                }
                completion(false)
            @unknown default:
                completion(false)
            }
        }
    }

    private func scheduleReminder(for medication: Medication, identifier: String) {
        guard let dateComponents = triggerDateComponents(
            forTimeString: medication.time,
            repeatOption: medication.repeatOption
        ) else { return }

        let content = UNMutableNotificationContent()
        content.title = "Medication Reminder"
        content.body = "Time to take \(medication.name)."
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        center.add(request)
    }

    private func triggerDateComponents(forTimeString timeString: String, repeatOption: String) -> DateComponents? {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.locale = Locale(identifier: "en_US_POSIX")

        guard let time = formatter.date(from: timeString) else { return nil }

        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
        var triggerComponents = DateComponents()
        triggerComponents.hour = timeComponents.hour
        triggerComponents.minute = timeComponents.minute

        if repeatOption != "Every Day" {
            triggerComponents.weekday = weekday(for: repeatOption)
        }

        return triggerComponents
    }

    private func weekday(for repeatOption: String) -> Int? {
        let mapping: [String: Int] = [
            "Every Sun": 1,
            "Every Mon": 2,
            "Every Tue": 3,
            "Every Wed": 4,
            "Every Thu": 5,
            "Every Fri": 6,
            "Every Sat": 7
        ]

        return mapping[repeatOption]
    }

    private func notificationIdentifier(for medicationID: String) -> String {
        identifierPrefix + medicationID
    }
}
