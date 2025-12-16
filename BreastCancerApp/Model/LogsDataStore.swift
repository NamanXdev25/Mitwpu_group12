import Foundation

class LogsDataStore {
    
    
    private var header: HeaderModel
    private var appointment: AppointmentModel
    private var stats: StatsModel
    private var medications: [MedicationModel] = []
    private var healthTracking: [HealthTrackingModel] = []
    
    
    static let shared = LogsDataStore()
    
    private init() {
        // Initialize with default values
        self.header = HeaderModel(title: "", date: "")
        self.appointment = AppointmentModel(title: "", doctorName: "", dateAndYear: "", time: "")
        self.stats = StatsModel(
            hydration: StatsModel.StatItem(title: "", currentValue: "", goalValue: "", subtitle: "", progress: 0),
            exercise: StatsModel.StatItem(title: "", currentValue: "", goalValue: "", subtitle: "", progress: 0)
        )
        
        // Load sample data
        loadSampleData()
    }
    
    // MARK: - Load Sample Data
    func loadSampleData() {
        // Header Data
        header = HeaderModel(
            title: "Logs",
            date: "Mon 20 Apr"
        )
        
        // Appointment Data
        appointment = AppointmentModel(
            title: "Upcoming Appointment",
            doctorName: "Dr. Sarah Johnson",
            dateAndYear: "Mon 22 Apr, 2024",
            time: "10:30 AM"
        )
        
        // Stats Data
        stats = StatsModel(
            hydration: StatsModel.StatItem(
                title: "Hydration",
                currentValue: "1.8",
                goalValue: "3L",
                subtitle: "Completed",
                progress: 0.6
            ),
            exercise: StatsModel.StatItem(
                title: "Exercise",
                currentValue: "2",
                goalValue: "4",
                subtitle: "Done",
                progress: 0.5
            )
        )
        
        // Medications Data
        medications = [
            MedicationModel(
                pillName: "Pill 2",
                time: "2:00 PM",
                instruction: "After Lunch",
                isCompleted: false
            )
        ]
        
        // Health Tracking Data
        healthTracking = [
            HealthTrackingModel(
                title: "Track Your Symptoms",
                lastTracked: "2 Days ago",
                iconName: "list.clipboard"
            ),
            HealthTrackingModel(
                title: "Self-Exam Steps",
                lastTracked: "23 Days ago",
                iconName: "heart"
            )
        ]
    }
    
   
    func getHeader() -> HeaderModel {
        return header
    }
    
    func getAppointment() -> AppointmentModel {
        return appointment
    }
    
    func getStats() -> StatsModel {
        return stats
    }
    
    func getMedications() -> [MedicationModel] {
        return medications
    }
    
    func getHealthTracking() -> [HealthTrackingModel] {
        return healthTracking
    }
    
    func getSectionHeader(for section: Int) -> SectionHeaderModel? {
        switch section {
        case 3:
            return SectionHeaderModel(title: "Medications", showManageButton: true)
        case 4:
            return SectionHeaderModel(title: "Health Tracking", showManageButton: false)
        default:
            return nil
        }
    }
    
   
    func getMedication(at index: Int) -> MedicationModel? {
        guard index < medications.count else { return nil }
        return medications[index]
    }
    
    func getHealthTrackingItem(at index: Int) -> HealthTrackingModel? {
        guard index < healthTracking.count else { return nil }
        return healthTracking[index]
    }
}
