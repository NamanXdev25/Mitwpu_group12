//
//  LogsSectionHeader.swift
//  BreastCancerApp
//
//  Created by Naman Bhansali on 14/12/25.
//

import UIKit

class LogsSectionHeader: UICollectionReusableView {
    // Make sure this matches the Identifier in your XIB file
    static let identifier = "LogsSectionHeader"
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var manageButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(title: String, showManage: Bool) {
        titleLabel.text = title
        // Hides the button if showManage is false (for Health Tracking section)
        manageButton.isHidden = !showManage
    }
}
