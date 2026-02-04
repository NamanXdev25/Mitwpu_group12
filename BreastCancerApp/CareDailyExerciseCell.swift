//
//  CareDailyExerciseCell.swift
//  BreastCancerApp
//
//  Created by Naman Bhansali on 04/02/26.
//

import UIKit

class CareDailyExerciseCell: UICollectionViewCell {

    @IBOutlet weak var ExerciseContainer: UIView!
    @IBOutlet weak var ExerciseImage: UIImageView!
    
    @IBOutlet weak var ExerciseTitle: UILabel!
    
    @IBOutlet weak var ExerciseTime: UILabel!
    
    @IBOutlet weak var ExerciseBeginButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
