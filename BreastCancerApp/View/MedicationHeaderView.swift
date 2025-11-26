//
//  MedicationHeaderView.swift
//  BreastCancerApp
//
//  Created by SDC-USER on 26/11/25.
//

import UIKit

class MedicationHeaderView: UICollectionReusableView {

    
    static let reuseIdentifier: String = "med_header"
    
    @IBOutlet weak var titleLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configure(with text: String) {
        titleLabel.text = text
    }
}

