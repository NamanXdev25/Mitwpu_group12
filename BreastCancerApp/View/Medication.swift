import Foundation

struct Medication {
    var name: String
    var note: String
    var time: String
    
    init(name: String = "", note: String = "", time: String = "") {
        self.name = name
        self.note = note
        self.time = time
    }
}
