import Foundation
import UIKit

struct Memory: Codable {
    let imageData: Data
    let date: Date
    let note: String?

    var image: UIImage? {
        UIImage(data: imageData)
    }
}
