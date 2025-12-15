//
//  HomeArticleCell.swift
//  BreastCancerApp
//
//  Created by Naman Bhansali on 15/12/25.
//

import UIKit

class HomeArticleCell: UICollectionViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var articleImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with model: HomeArticleModel) {
        titleLabel.text = model.title
        subtitleLabel.text = model.subtitle
        articleImageView.image = UIImage(named: model.imageName)
    }
}
