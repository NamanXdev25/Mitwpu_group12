import UIKit

extension Memory {
    var image: UIImage? {
        guard let data = imageData else { return nil }
        return UIImage(data: data)
    }

    init(
        id: String = UUID().uuidString,
        image: UIImage?,
        date: Date,
        note: String?
    ) {
        self.id = id
        imageData = image?.jpegData(compressionQuality: 0.8)
        self.date = date
        self.note = note
    }
}
