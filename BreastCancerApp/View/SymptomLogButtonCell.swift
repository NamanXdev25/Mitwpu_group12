//
//  SymptomLogButtonCell.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 08/01/26.
//

import UIKit

class SymptomLogButtonCell: UICollectionViewCell {

    @IBOutlet weak var logButton: UIButton!
    
    var onButtonTapped: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        logButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    func configure(isEnabled: Bool) {
        logButton.isEnabled = isEnabled
        logButton.alpha = isEnabled ? 1.0 : 0.5
    }
    
    @objc private func buttonTapped() {
        onButtonTapped?()
    }

}
