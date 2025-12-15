//
//  HeaderCell.swift
//  BreastCancerApp
//
//  Created by Naman Bhansali on 14/12/25.
//

import UIKit

class HeaderCell: UICollectionViewCell {
    // 1. We need this identifier for the Controller to find the cell
    static let identifier = "HeaderCell"
    
    // 2. Renamed to standard camelCase (matches previous Controller code)
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    // Store reference to gradient layer to update it
    private var gradientLayer: CAGradientLayer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Add the gradient when cell is created
        addBottomGradient()
    }
    
    // 3. Your configure function (Excellent practice!)
    func configure(title: String, date: String) {
        titleLabel.text = title
        dateLabel.text = date
    }
    
    // MARK: - Gradient Logic
    private func addBottomGradient() {
        // Remove existing gradient if any
        gradientLayer?.removeFromSuperlayer()
        
        // Create a gradient layer
        let gradient = CAGradientLayer()
        
        // Colors: Clear (top) -> White (bottom)
        gradient.colors = [
            UIColor.clear.cgColor,
            UIColor.white.withAlphaComponent(0.4).cgColor,
            UIColor.white.cgColor
        ]
        
        // Locations: Start fading earlier for better coverage
        gradient.locations = [0.0, 0.65, 1.0]
        
        // Add to the cell's layer (not image view) so it can extend beyond
        contentView.layer.addSublayer(gradient)
        self.gradientLayer = gradient
        
        // Send it behind everything except the background image
        if let imageView = backgroundImageView {
            contentView.layer.insertSublayer(gradient, above: imageView.layer)
        }
    }
    
    // Ensure gradient resizes with the cell
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Position gradient to cover the full cell width and extend downward
        let gradientHeight: CGFloat = contentView.bounds.height + 50 // Extend 50pts beyond
        gradientLayer?.frame = CGRect(
            x: 0,
            y: 0,
            width: contentView.bounds.width, // Full screen width
            height: gradientHeight
        )
    }
}
