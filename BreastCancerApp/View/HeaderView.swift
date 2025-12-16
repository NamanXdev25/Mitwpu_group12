//
//  HeaderView.swift
//  ChemoCompanion
//
//  Created  by Shloka on 28/11/25.
//

import UIKit

class HeaderView: UICollectionReusableView {

    // OUTLET
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // No special styling needed yet
    }
    
    func configureHeader(text: String) {
        titleLabel.text = text
    }
    
}
