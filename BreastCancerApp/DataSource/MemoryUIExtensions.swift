//
//  MemoryUIExtensions.swift
//  BreastCancerApp
//
//  Created by Naman Bhansali on 01/03/26.
//

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
        self.imageData = image?.jpegData(compressionQuality: 0.8)
        self.date = date
        self.note = note
    }
}
