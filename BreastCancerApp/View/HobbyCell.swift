//
//  HobbyCell.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 13/01/26.
//

import UIKit

class HobbyCell: UICollectionViewCell {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
        
        contentView.layer.cornerRadius = 20
        contentView.backgroundColor = UIColor(named: "OnboardingLightPink")
    }
    
    func configure(with hobby: String, isSelected: Bool) {
        titleLabel.text = hobby
        
        if isSelected {
            contentView.backgroundColor = UIColor(named: "OnboardingPrimaryColor")
            titleLabel.textColor = .white
        } else {
            contentView.backgroundColor = UIColor(named: "OnboardingLightPink")
            titleLabel.textColor = .black
        }
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 0)
        layoutAttributes.frame.size = contentView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        return layoutAttributes
    }
}
