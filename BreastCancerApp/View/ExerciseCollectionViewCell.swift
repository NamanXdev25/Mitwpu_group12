//
//  ExerciseCollectionViewCell.swift
//  BreastCancerApp
//
//  Created by Shloka on 02/02/26.
//

import UIKit

class ExerciseCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var exerciseGraphView: BarGraphView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var barChartContainerView: UIView!
    @IBOutlet weak var dayActiveValueLabel: UILabel!
    @IBOutlet weak var totalMinutesValueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
