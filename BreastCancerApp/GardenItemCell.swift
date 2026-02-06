//
//  GardenItemCell.swift
//  healinggarden2
//
//  Created by Naman Bhansali on 27/01/26.
//

import UIKit

class GardenItemCell: UICollectionViewCell {
    
    // Outlets to be connected in Storyboard
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var separatorView: UIView! // The vertical line on the right
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Styling the cell
        itemImageView.contentMode = .scaleAspectFit
        titleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        titleLabel.textColor = .darkGray
        titleLabel.textAlignment = .center
        
        // Styling the separator
        separatorView.backgroundColor = UIColor.systemGray5
    }
    
    // FIX: Changed 'GardenItem' to 'StoreItem' and 'item.title' to 'item.name'
    func configure(with item: StoreItem, isLast: Bool) {
        itemImageView.image = UIImage(named: item.imageName)
        titleLabel.text = item.name
        
        // Hide separator for the very last item in the list
        separatorView.isHidden = isLast
    }
}
