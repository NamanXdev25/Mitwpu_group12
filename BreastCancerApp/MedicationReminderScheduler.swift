import Foundation
import UserNotifications

final class MedicationReminderScheduler {
    static let shared = MedicationReminderScheduler()

    private let center = UNUserNotificationCenter.current()
    private let identifierPrefix = "medication-reminder-"

    private init() {}

    func syncReminders(for medications: [Medication], showPermissionAlert: Bool = true) {
        removeAllPendingReminders { [weak self] in
            guard let self else { return }

            let enabledMedications = medications.filter(\.reminderEnabled)
            guard !enabledMedications.isEmpty else { return }

            self.requestAuthorizationIfNeeded(showPermissionAlert: showPermissionAlert) { granted in
                guard granted else { return }
                self.scheduleGroupedReminders(for: enabledMedications)
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

    private func scheduleGroupedReminders(for medications: [Medication]) {
        let grouped = Dictionary(grouping: medications, by: triggerKey(for:))

        for (key, group) in grouped {
            guard let first = group.first,
                  let dateComponents = triggerDateComponents(
                    forTimeString: first.time,
                    repeatOption: first.repeatOption
                  )
            else { continue }

            let content = UNMutableNotificationContent()
            content.title = "Medication Reminder"
            content.body = reminderBody(for: group)
            content.sound = .default

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(
                identifier: notificationIdentifier(for: key),
                content: content,
                trigger: trigger
            )
            center.add(request)
        }
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

    private func triggerKey(for medication: Medication) -> String {
        let weekdayKey = weekday(for: medication.repeatOption).map(String.init) ?? "daily"
        return "\(weekdayKey)-\(medication.time.lowercased())"
    }

    private func notificationIdentifier(for key: String) -> String {
        identifierPrefix + key.replacingOccurrences(of: " ", with: "-")
    }

    private func reminderBody(for medications: [Medication]) -> String {
        let names = medications.map(\.name)

        if names.count == 1, let name = names.first {
            return "Time to take \(name)."
        }

        if names.count == 2 {
            return "Time to take \(names[0]) and \(names[1])."
        }

        let preview = names.prefix(3).joined(separator: ", ")
        let remaining = names.count - min(names.count, 3)
        return "Time to take \(preview), and \(remaining) more medications."
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
