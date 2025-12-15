//
//  GuidesContainerCell.swift
//  BreastCancerApp
//
//  Created by Gayatri Goundadkar on 06/12/25.
//

import UIKit

class GuidesContainerCell: UICollectionViewCell {
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var row1Label: UILabel!
    @IBOutlet weak var row1Chevron: UIImageView!
    @IBOutlet weak var row2Label: UILabel!
    @IBOutlet weak var row2Chevron: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cardView.layer.cornerRadius = 12
        cardView.layer.masksToBounds = true
        cardView.backgroundColor = .white
        
        let chevronColor = UIColor(named: "ChevronGray") ?? .lightGray
        
        // Apply template mode + tint
        let chevron = UIImage(systemName: "chevron.right")?.withRenderingMode(.alwaysTemplate)
        row1Chevron.image = chevron
        row2Chevron.image = chevron
        
        row1Chevron.tintColor = chevronColor
        row2Chevron.tintColor = chevronColor
        
        row1Chevron.contentMode = .center
        row2Chevron.contentMode = .center
        
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        row1Label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        row2Label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
    }
    
    }
