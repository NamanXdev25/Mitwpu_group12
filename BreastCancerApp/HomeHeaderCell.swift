//
//  HomeHeaderCell.swift
//  BreastCancerApp
//
//  Created by Naman Bhansali on 02/02/26.
//

import UIKit

class HomeHeaderCell: UICollectionReusableView {
    
    @IBOutlet weak var HeaderTitleLabel: UILabel!
    @IBOutlet weak var seeAllLabel: UILabel!
    
    // Callback for "See All" label tap
    var onSeeAllTapped: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Make the label tappable
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(seeAllLabelTapped))
        seeAllLabel.isUserInteractionEnabled = true
        seeAllLabel.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Configure
    func configure(title: String, showSeeAll: Bool = false) {
        HeaderTitleLabel.text = title
        seeAllLabel.isHidden = !showSeeAll
    }
    
    @objc private func seeAllLabelTapped() {
        onSeeAllTapped?()
    }
}
