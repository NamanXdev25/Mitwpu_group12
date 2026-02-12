import Foundation

struct WaitModel {
    var status: String = "Not Started"
    var daysWaited: Int?
    var selectedFeelings: Set<String> = []
}

struct Suggestion {
    let title: String
    let description: String
    let relatedFeelings: [String]
}
