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
            title: "Insights",
            date: formatCurrentDate()
        )
        
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
    
    // MARK: - Get Next Medication (Latest untaken medicine)
    func getNextMedication() -> MedicationModel? {
        // Get today's medications from MedicationHistory
        let history = MedicationHistory.shared.getHistory(for: Date())
        
        // If no history exists for today, initialize it with default medications
        let allMedications: [Medication]
        if let existingHistory = history {
            allMedications = existingHistory.medications
        } else {
            // Load default medications for today
            let defaultMedications = getDefaultMedications()
            MedicationHistory.shared.saveMedications(defaultMedications, for: Date())
            allMedications = defaultMedications
        }
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        timeFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        // Filter medications scheduled for today
        let todaysMeds = allMedications.filter { $0.isScheduledFor(date: Date()) }
        
        // If no medications for today, return nil
        if todaysMeds.isEmpty {
            return nil
        }
        
        // Get all untaken medications
        let untakenMeds = todaysMeds.filter { !$0.isTaken }
        
        // Sort by time (ascending)
        let sortedUntaken = untakenMeds.sorted { med1, med2 in
            if let date1 = timeFormatter.date(from: med1.time),
               let date2 = timeFormatter.date(from: med2.time) {
                return date1 < date2
            }
            return med1.time < med2.time
        }
        
        // Return the first (earliest) untaken medication
        guard let nextMed = sortedUntaken.first else {
            return nil
        }
        
        // Convert to MedicationModel
        return MedicationModel(
            pillName: nextMed.name,
            time: nextMed.time,
            instruction: nextMed.note.isEmpty ? nextMed.repeatOption : nextMed.note,
            isCompleted: nextMed.isTaken
        )
    }
    
    // MARK: - Get Default Medications
    private func getDefaultMedications() -> [Medication] {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: Date())
        
        var defaultMeds: [Medication] = [
            Medication(name: "Aspirin", note: "Take with food", time: "8:00 AM", repeatOption: "Every Day", isTaken: false, reminderEnabled: true),
            Medication(name: "Vitamin D", note: "Morning supplement", time: "9:00 AM", repeatOption: "Every Day", isTaken: false, reminderEnabled: true),
            Medication(name: "Blood Pressure Med", note: "", time: "12:00 PM", repeatOption: "Every Day", isTaken: false, reminderEnabled: true),
            Medication(name: "Thyroid Medicine", note: "Take on empty stomach", time: "7:00 AM", repeatOption: "Every Day", isTaken: false, reminderEnabled: true),
            Medication(name: "Allergy Medicine", note: "Only if needed", time: "10:00 PM", repeatOption: "Every Day", isTaken: false, reminderEnabled: true)
        ]
        
        // Add weekday-specific medications
        if weekday == 2 { // Monday
            defaultMeds.append(Medication(name: "Omega-3", note: "", time: "6:00 PM", repeatOption: "Every Mon", isTaken: false, reminderEnabled: false))
        }
        
        return defaultMeds
    }
    
    // MARK: - Check if all medications are taken
    func areAllMedicationsTaken() -> Bool {
        let history = MedicationHistory.shared.getHistory(for: Date())
        
        let allMedications: [Medication]
        if let existingHistory = history {
            allMedications = existingHistory.medications
        } else {
            // If no history, medications haven't been initialized yet
            return false
        }
        
        let todaysMeds = allMedications.filter { $0.isScheduledFor(date: Date()) }
        
        // If no medications scheduled for today, return false
        if todaysMeds.isEmpty {
            return false
        }
        
        // Check if all are taken
        return todaysMeds.allSatisfy { $0.isTaken }
    }
    
    // MARK: - Check if any medications exist
    func hasMedications() -> Bool {
        let history = MedicationHistory.shared.getHistory(for: Date())
        
        let allMedications: [Medication]
        if let existingHistory = history {
            allMedications = existingHistory.medications
        } else {
            // Check if there would be default medications
            let defaultMeds = getDefaultMedications()
            return !defaultMeds.isEmpty
        }
        
        let todaysMeds = allMedications.filter { $0.isScheduledFor(date: Date()) }
        return !todaysMeds.isEmpty
    }
    
    // MARK: - Toggle Medication Status
    func toggleMedicationStatus(pillName: String, time: String) {
        guard let history = MedicationHistory.shared.getHistory(for: Date()) else { return }
        
        var medications = history.medications
        
        // Find and toggle the medication
        if let index = medications.firstIndex(where: {
            $0.name == pillName && $0.time == time && $0.isScheduledFor(date: Date())
        }) {
            medications[index].isTaken.toggle()
            
            // Save back to history
            MedicationHistory.shared.saveMedications(medications, for: Date())
            
            // Post notification to update MedicationViewController
            NotificationCenter.default.post(
                name: NSNotification.Name("MedicationDataUpdated"),
                object: nil
            )
        }
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
