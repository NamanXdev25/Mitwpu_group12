import Foundation

enum CareItemType {
    case hydration
    case hydrationDetail
    case medication
    case exercise
    case symptoms
    case appointmentsHeader
    case appointment
    case healthInsights
}

struct CareItem {
    let type: CareItemType
    var isExpanded: Bool = false
    // You can add more properties here like titles, images, or progress values
}
