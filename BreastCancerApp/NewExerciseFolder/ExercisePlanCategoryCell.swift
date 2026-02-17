//
//  ExercisePlanCategoryCell.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 13/02/26.
//

import UIKit

class ExercisePlanCategoryCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with category: ExercisePlanCategory) {
        titleLabel.text = category.title
        subtitleLabel.text = category.subtitle
        
        // Set image if available, otherwise keep placeholder background
        if let imageName = category.imageName {
            imageView.image = UIImage(named: imageName)
        } else {
            imageView.image = nil
        }
    }
}
