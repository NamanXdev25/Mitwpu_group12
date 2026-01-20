//
//  ArticleContentCell.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 10/01/26.
//

import UIKit

class ArticleContentCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func configure(title: String, content: String) {
        titleLabel.text = title
        contentLabel.text = content
        
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        setNeedsLayout()
        layoutIfNeeded()
        
        let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
        var frame = layoutAttributes.frame
        frame.size.height = ceil(size.height)
        
        layoutAttributes.frame = frame
        return layoutAttributes
    }
}
