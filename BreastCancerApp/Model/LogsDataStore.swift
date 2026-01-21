import Foundation

class LogsDataStore {
    
    private var header: HeaderModel
    private var medications: [MedicationModel] = []
    private var healthTracking: [HealthTrackingModel] = []
    
    static let shared = LogsDataStore()
    
    private init() {
        // Initialize with default values
        self.header = HeaderModel(title: "", date: "")
        
        // Load sample data
        loadSampleData()
    }
    
    // MARK: - Load Sample Data
    func loadSampleData() {
        // Header Data
        header = HeaderModel(
            title: "Logs",
            date: formatCurrentDate()
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
    
    private func formatCurrentDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE dd MMM"
        return formatter.string(from: Date())
    }
    
    func getHeader() -> HeaderModel {
        return header
    }
    
    func getAppointment() -> AppointmentModel? {
        // Get the nearest upcoming appointment
        return getNearestAppointment()
    }
    
    // MARK: - Get Nearest Upcoming Appointment
    private func getNearestAppointment() -> AppointmentModel? {
        let calendar = Calendar.current
        let now = Date()
        
        // Get all appointments from AppointmentManager
        let allDates = AppointmentManager.shared.getAllDatesWithAppointments()
        
        var nearestAppointment: AppointmentItem?
        var nearestDate: Date?
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        timeFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        // Loop through all dates
        for dateString in allDates {
            guard let date = dateFormatter.date(from: dateString) else { continue }
            
            // Get appointments for this date
            let appointments = AppointmentManager.shared.getAppointments(for: date)
            
            for appointment in appointments {
                // Parse the appointment time
                guard let time = timeFormatter.date(from: appointment.time) else { continue }
                
                // Combine date and time
                let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
                let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
                
                var fullComponents = dateComponents
                fullComponents.hour = timeComponents.hour
                fullComponents.minute = timeComponents.minute
                
                guard let fullDate = calendar.date(from: fullComponents) else { continue }
                
                // Only consider future appointments
                if fullDate > now {
                    if nearestDate == nil || fullDate < nearestDate! {
                        nearestDate = fullDate
                        nearestAppointment = appointment
                    }
                }
            }
        }
        
        // Convert to AppointmentModel if found
        if let appointment = nearestAppointment {
            // Use note as doctorName, or show category if note is empty
            let displayText = !appointment.note.isEmpty ? appointment.note : appointment.category
            
            return AppointmentModel(
                title: appointment.title,
                doctorName: displayText,
                dateAndYear: appointment.date,
                time: appointment.time
            )
        }
        
        return nil
    }
    
    private func extractDoctorName(from appointment: AppointmentItem) -> String {
        // This method is no longer used, but keeping for backward compatibility
        if appointment.category.contains("Doctor") {
            return "Doctor Visit"
        } else if appointment.category.contains("Chemo") {
            return "Chemotherapy Session"
        }
        return appointment.category
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
