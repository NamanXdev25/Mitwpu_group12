//
//  CareMedicationCell.swift
//  BreastCancerApp
//
//  Created by Naman Bhansali on 04/02/26.
//

import UIKit

class CareMedicationCell: UICollectionViewCell {

    @IBOutlet weak var MedicationConatiner: UIView!
    @IBOutlet weak var MedicationImage: UIImageView!
    
    
    @IBOutlet weak var MedicationLabel: UILabel!
    
    @IBOutlet weak var TakenLabel: UILabel!
    
    @IBOutlet weak var MedicationInfoButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
