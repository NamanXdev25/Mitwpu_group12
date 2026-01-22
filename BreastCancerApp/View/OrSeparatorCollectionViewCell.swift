//
//  OrSeparatorCollectionViewCell.swift
//  BreastCancerApp
//
//  Created by Shloka on 19/01/26.
//

import UIKit

class OrSeparatorCollectionViewCell: UICollectionViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.isUserInteractionEnabled = true
        isUserInteractionEnabled = true

        backgroundColor = .white
        contentView.backgroundColor = .white
    }
}

