//
//  HobbyCell.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 13/01/26.
//

import UIKit

class HobbyCell: UICollectionViewCell {
    
    // MARK: - Outlets
    @IBOutlet private weak var containerView: UIView! // Tag 100
    @IBOutlet private weak var titleLabel: UILabel!   // Tag 101
    
    // MARK: - Initialization
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        // Initial unselected state
        updateAppearance(isSelected: false)
    }
    
    // MARK: - Configuration
    func configure(with hobby: String, isSelected: Bool) {
        titleLabel.text = hobby
        updateAppearance(isSelected: isSelected)
    }
    
    private func updateAppearance(isSelected: Bool) {
        if isSelected {
            containerView.backgroundColor = UIColor(named: "OnboardingPrimaryColor")
            titleLabel.textColor = .white
        } else {
            containerView.backgroundColor = UIColor(named: "OnboardingBackgroundColor")
            titleLabel.textColor = .black
        }
    }
    
    // MARK: - Dynamic Sizing
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        setNeedsLayout()
        layoutIfNeeded()
        
        // Calculate width based on label
        let targetSize = CGSize(width: UIView.layoutFittingCompressedSize.width,
                               height: UIView.layoutFittingCompressedSize.height)
        let size = contentView.systemLayoutSizeFitting(targetSize,
                                                       withHorizontalFittingPriority: .fittingSizeLevel,
                                                       verticalFittingPriority: .required)
        
        var frame = layoutAttributes.frame
        frame.size.width = ceil(size.width)
        frame.size.height = 40 // Fixed height for all cells
        layoutAttributes.frame = frame
        
        return layoutAttributes
    }
}
