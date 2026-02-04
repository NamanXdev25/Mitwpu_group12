//
//  CareViewInsightsCell.swift
//  BreastCancerApp
//
//  Created by Naman Bhansali on 04/02/26.
//

import UIKit

class CareViewInsightsCell: UICollectionViewCell {

    @IBOutlet weak var InsightsContainer: UIView!
    @IBOutlet weak var InsightCellImage: UIImageView!
    
    @IBOutlet weak var InsightCellLabel: NSLayoutConstraint!
    
    @IBOutlet weak var InsightCellChevronButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
