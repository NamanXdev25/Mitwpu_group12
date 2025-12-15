//
//  HomeHeaderCell.swift
//  BreastCancerApp
//
//  Created by Naman Bhansali on 14/12/25.
//

import UIKit

class HomeHeaderCell: UICollectionViewCell {
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileButton: UIButton!
    
    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet weak var subGreetingLabel: UILabel!
    
    // Removed quoteContainerView outlet
    @IBOutlet weak var quoteLabel: UILabel!
    
    private var gradientLayer: CAGradientLayer?


    override func awakeFromNib() {
        super.awakeFromNib()
        // Add the gradient when cell is created
        addBottomGradient()
    }
    
    func configure(name: String) {
        greetingLabel.text = "Hello, \(name)!"
    }
    
    
    @IBAction func profileTapped(_ sender: UIButton) {
        print("Profile tapped!")
    }
    
    private func addBottomGradient() {
        // Remove existing gradient if any
        gradientLayer?.removeFromSuperlayer()
        
        // Create a gradient layer
        let gradient = CAGradientLayer()
        
        // Colors: Clear (top) -> White (bottom)
        gradient.colors = [
            UIColor.clear.cgColor,
            UIColor.white.withAlphaComponent(0.4).cgColor,
            UIColor.white.withAlphaComponent(0.9).cgColor
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


