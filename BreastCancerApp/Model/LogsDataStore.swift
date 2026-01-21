import Foundation

class LogsDataStore {
    
    private var header: HeaderModel
    private var appointment: AppointmentModel
    private var medications: [MedicationModel] = []
    private var healthTracking: [HealthTrackingModel] = []
    
    static let shared = LogsDataStore()
    
    private init() {
        // Initialize with default values
        self.header = HeaderModel(title: "", date: "")
        self.appointment = AppointmentModel(title: "", doctorName: "", dateAndYear: "", time: "")
        
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
            title: "Oncology Check-Up",
            doctorName: "Dr. Sarah Johnson",
            dateAndYear: "22 Apr 2025",
            time: "10:30 AM"
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
    
    // MARK: - Get Stats with Real-time Data
    func getStats() -> StatsModel {
        // Get Exercise Data
        let exerciseManager = ExerciseManager.shared
        let todayPlan = exerciseManager.currentDayPlan
        let totalExercises = todayPlan.count
        let completedExercises = todayPlan.filter { $0.isCompleted }.count
        let exerciseProgress = totalExercises > 0 ? Float(completedExercises) / Float(totalExercises) : 0.0
        
        // Get Hydration Data
        let consumedML = HydrationModel.consumedTodayML()
        let consumedLiters = Double(consumedML) / 1000.0
        let goalLiters = HydrationModel.currentGoal()
        let hydrationProgress = Float(consumedLiters / goalLiters)
        
        return StatsModel(
            hydration: StatsModel.StatItem(
                title: "Hydration",
                currentValue: String(format: "%.1f", consumedLiters),
                goalValue: String(format: "%.1fL", goalLiters),
                subtitle: "Completed",
                progress: min(hydrationProgress, 1.0) // Cap at 100%
            ),
            exercise: StatsModel.StatItem(
                title: "Exercise",
                currentValue: "\(completedExercises)",
                goalValue: "\(totalExercises)",
                subtitle: "Done",
                progress: exerciseProgress
            )
        )
    }
    
    func getMedications() -> [MedicationModel] {
        return medications
    }
    
    func getHealthTracking() -> [HealthTrackingModel] {
        return healthTracking
    }
    
    func getSectionHeader(for section: Int) -> SectionHeaderModel? {
        switch section {
        case 2:
            return SectionHeaderModel(title: "Appointments", showManageButton: true)
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
