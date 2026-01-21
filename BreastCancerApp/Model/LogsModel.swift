import Foundation

struct HeaderModel {
    let title: String
    let date: String
}

struct AppointmentModel {
    let title: String
    let doctorName: String
    let dateAndYear: String
    let time: String
}

struct StatsModel {
    let hydration: StatItem
    let exercise: StatItem
    
    struct StatItem {
        let title: String
        let currentValue: String
        let goalValue: String
        let subtitle: String
        let progress: Float
        
        var displayValue: String {
            return currentValue
        }
        
        var displaySubtitle: String {
            return "of \(goalValue) \(subtitle)"
        }
    }
}

struct MedicationModel {
    let pillName: String
    let time: String
    let instruction: String
    var isCompleted: Bool
}

struct HealthTrackingModel {
    let title: String
    let lastTracked: String
    let iconName: String
    
    var displayLastTracked: String {
        return "Last: \(lastTracked)"
    }
}

struct SectionHeaderModel {
    let title: String
    let showManageButton: Bool
}
