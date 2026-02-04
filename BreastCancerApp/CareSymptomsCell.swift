//
//  CareSymptomsCell.swift
//  BreastCancerApp
//
//  Created by Naman Bhansali on 04/02/26.
//

import UIKit

class CareSymptomsCell: UICollectionViewCell {

    @IBOutlet weak var SymptomsContainer: UIView!
    @IBOutlet weak var SymptomsLabel: UILabel!
    
    @IBOutlet weak var InsightCellCollectionView: UICollectionView!
    
    @IBOutlet weak var SeperatorView: UIView!
    
    
    @IBOutlet weak var ViewInsightsButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
