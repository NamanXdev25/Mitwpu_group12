import UIKit

struct Memory: Codable {
    let imageData: Data?
    let date: Date
    let note: String?
    
    // Computed property for easy UIImage access
    var image: UIImage? {
        guard let data = imageData else { return nil }
        return UIImage(data: data)
    }
    
    // Initializer that accepts UIImage
    init(image: UIImage?, date: Date, note: String?) {
        self.imageData = image?.jpegData(compressionQuality: 0.8)
        self.date = date
        self.note = note
    }
    
    // Codable synthesized init/encode will handle imageData, date, note automatically
}
