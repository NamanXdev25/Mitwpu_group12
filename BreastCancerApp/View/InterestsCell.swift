//
//  InterestsCell.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 14/01/26.
//

import UIKit

class InterestsCell: UICollectionViewCell {
    
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    
    var isSelectedCell: Bool = false {
        didSet {
            updateSelectionState()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        updateSelectionState()
    }
    
    func configure(with title: String, icon: String, isSelected: Bool) {
        titleLabel.text = title
        iconImageView.image = UIImage(systemName: icon)
        isSelectedCell = isSelected
    }
    
    private func updateSelectionState() {
        if isSelectedCell {
            containerView.layer.borderWidth = 2
            containerView.layer.borderColor = UIColor(named: "OnboardingPrimaryColor")?.cgColor
        } else {
            containerView.layer.borderWidth = 0
        }
    }
}
