import Foundation

struct Medication {
    var name: String
    var note: String
    var time: String
    var repeatOption: String
    var isTaken: Bool = false
    var reminderEnabled: Bool = true
    
    func isScheduledFor(date: Date) -> Bool {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        
        if repeatOption == "Every Day" {
            return true
        }
        
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
