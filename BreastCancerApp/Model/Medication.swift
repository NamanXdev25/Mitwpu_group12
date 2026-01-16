import Foundation

struct Medication {
    var name: String
    var note: String
    var time: String
    var repeatOption: String  // Store the actual repeat option (e.g., "Every Mon", "Every Day")
    var isTaken: Bool = false
    var reminderEnabled: Bool = true  // Store reminder switch state
    
    // Helper function to check if medication is scheduled for a given date
    func isScheduledFor(date: Date) -> Bool {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        
        // If it's "Every Day", it's scheduled for all days
        if repeatOption == "Every Day" {
            return true
        }
        
        // Map weekday numbers to repeat options
        // Sunday = 1, Monday = 2, Tuesday = 3, etc.
        let weekdayMap: [Int: String] = [
            1: "Every Sun",
            2: "Every Mon",
            3: "Every Tue",
            4: "Every Wed",
            5: "Every Thu",
            6: "Every Fri",
            7: "Every Sat"
        ]
        
        return repeatOption == weekdayMap[weekday]
    }
}
