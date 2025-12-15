//
//  HomeMemoryCell.swift
//  BreastCancerApp
//
//  Created by Naman Bhansali on 15/12/25.
//

import UIKit

class HomeMemoryCell: UICollectionViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var memoryImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func configure(with model: HomeMemoryModel) {
        memoryImageView.image = UIImage(named: model.imageName)
        
        // Mapping model data to the new labels
        titleLabel.text = model.date
        subtitleLabel.text = model.description
    }
}
