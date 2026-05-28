import Foundation

class OnboardingData {
    static let shared = OnboardingData()

    var userName: String = "User"
    var treatmentStatus: String?

    var diagnosisDate: Date?
    var currentAge: String?
    var currentStage: String?

    var lastCheckupDate: Date?
    var followUpFrequency: String?

    var treatmentCompletionDate: Date?
    var selectedInterests: [String] = []

    var selectedHobbies: [String] = []

    var currentTreatmentPhase: String?

    var maintenanceTherapy: String?

    var currentFocus: [String] = []

    private init() {}

    func reset() {
        userName = "User"
        treatmentStatus = nil
        diagnosisDate = nil
        currentAge = nil
        currentStage = nil
        selectedHobbies.removeAll()
        lastCheckupDate = nil
        followUpFrequency = nil
        treatmentCompletionDate = nil
        selectedInterests.removeAll()
        currentTreatmentPhase = nil
        maintenanceTherapy = nil
        currentFocus.removeAll()
    }

    func isComplete() -> Bool {
        return treatmentStatus != nil &&
            diagnosisDate != nil &&
            currentAge != nil &&
            currentStage != nil &&
            !selectedHobbies.isEmpty
    }

    func getApproximateAge() -> Int {
        guard let ageRange = currentAge else { return 32 }

        if ageRange.contains("-") {
            let components = ageRange.split(separator: "-")
            if components.count == 2,
               let lowerBound = Int(components[0]),
               let upperBound = Int(components[1]) {
                return (lowerBound + upperBound) / 2
            }
        }

        if ageRange.lowercased().contains("below 18") {
            return 16
        }
        if ageRange.contains("75+") {
            return 77
        }
        return 32
    }

    func formatDateForProfile(_ date: Date?) -> String {
        guard let date = date else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.string(from: date)
    }

    func getTreatmentState() -> String {
        guard let status = treatmentStatus else { return "Unknown" }

        switch status {
        case "Currently in treatment":
            return "Ongoing"
        case "Under Observation":
            return "Observation"
        case "Post-treatment / in recovery":
            return "Completed"
        case "Prefer not to say":
            return "Not Specified"
        default:
            return "Unknown"
        }
    }
}
