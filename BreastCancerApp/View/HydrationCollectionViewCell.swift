//
//  HydrationCollectionViewCell.swift
//  BreastCancerApp
//
//  Created by Shloka on 02/02/26.
//

import UIKit

class HydrationCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var hydrationGraphView: LineGraphView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var subtitle2Label: UILabel!
    @IBOutlet weak var graphContainerView: UIView!
    @IBOutlet weak var averageValueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
