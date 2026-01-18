import Foundation

struct HealthStatusModel {

    // MARK: - Identity
    let firstName: String
    let lastName: String

    // MARK: - Medical Information
    let diagnosisDate: Date
    let gender: String
    let age: Int
    let cancerStage: String
    let treatmentState: String
}

// MARK: - Convenience
extension HealthStatusModel {

    var fullName: String {
        firstName + " " + lastName
    }
}
