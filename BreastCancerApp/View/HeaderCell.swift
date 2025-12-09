//
//  HeaderCell.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 09/12/25.
//

import UIKit

class HeaderCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
    }

}
