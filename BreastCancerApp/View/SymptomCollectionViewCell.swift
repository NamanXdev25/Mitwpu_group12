//
//  SymptomCollectionViewCell.swift
//  BreastCancerApp
//
//  Created by Shloka on 03/02/26.
//

import UIKit

class SymptomCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var subtitleLabel: UILabel!
    
    @IBOutlet weak var symptomsLineGraphView: UIView!
    
    @IBOutlet weak var footerLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
