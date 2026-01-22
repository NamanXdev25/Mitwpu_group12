import UIKit

struct ProfileUserProfile: Codable {

    // MARK: - Identity
    var firstName: String
    var lastName: String
    var profileImageBase64: String?

    // MARK: - Medical Information
    var diagnosisDate: String
    var gender: String
    var age: Int
    var cancerStage: String
    var treatmentState: String
    var treatmentCompletionDate: String

    // MARK: - Notification Settings
    var exerciseNotificationsEnabled: Bool
    var hydrationNotificationsEnabled: Bool
    var appointmentsNotificationsEnabled: Bool
    var medicationsNotificationsEnabled: Bool

    // MARK: - Computed Properties (not stored in JSON)

    var fullName: String {
        if lastName.isEmpty {
            return firstName
        }
        return "\(firstName) \(lastName)"
    }

    var profileImage: UIImage? {
        get {
            guard let base64 = profileImageBase64,
                  let data = Data(base64Encoded: base64) else {
                return nil
            }
            return UIImage(data: data)
        }
        set {
            if let image = newValue,
               let data = image.jpegData(compressionQuality: 0.8) {
                profileImageBase64 = data.base64EncodedString()
            } else {
                profileImageBase64 = nil
            }
        }
    }

    var diagnosisDateObject: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.date(from: diagnosisDate)
    }

    var ageString: String {
        "\(age)"
    }
    
    var treatmentCompletionDateObject: Date? {
        guard !treatmentCompletionDate.isEmpty else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.date(from: treatmentCompletionDate)
    }

    // MARK: - Initializer

    init(
        firstName: String = "Sophie",
        lastName: String = "Chen",
        profileImage: UIImage? = nil,
        diagnosisDate: String = "12 Aug 2024",
        gender: String = "Female",
        age: Int = 32,
        cancerStage: String = "Stage II",
        treatmentState: String = "Ongoing",
        treatmentCompletionDate: String = "",
        exerciseNotificationsEnabled: Bool = false,
        hydrationNotificationsEnabled: Bool = false,
        appointmentsNotificationsEnabled: Bool = false,
        medicationsNotificationsEnabled: Bool = false
    ) {
        self.firstName = firstName
        self.lastName = lastName
        self.diagnosisDate = diagnosisDate
        self.gender = gender
        self.age = age
        self.cancerStage = cancerStage
        self.treatmentState = treatmentState
        self.treatmentCompletionDate = treatmentCompletionDate

        self.exerciseNotificationsEnabled = exerciseNotificationsEnabled
        self.hydrationNotificationsEnabled = hydrationNotificationsEnabled
        self.appointmentsNotificationsEnabled = appointmentsNotificationsEnabled
        self.medicationsNotificationsEnabled = medicationsNotificationsEnabled

        self.profileImage = profileImage
    }
}
