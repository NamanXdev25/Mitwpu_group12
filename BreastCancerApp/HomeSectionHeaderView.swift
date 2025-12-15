//
//  HomeSectionHeaderView.swift
//  BreastCancerApp
//
//  Created by Naman Bhansali on 15/12/25.
//

import UIKit

class HomeSectionHeaderView: UICollectionReusableView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var seeAllButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Optional: Add button action target here if needed
    }
    
    @IBAction func seeAllTapped(_ sender: UIButton) {
        print("See All Tapped")
    }
}
