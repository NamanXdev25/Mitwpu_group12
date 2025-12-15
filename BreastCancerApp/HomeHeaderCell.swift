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

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Round the Profile Image View
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.backgroundColor = .systemGray5
        
        profileImageView.layer.borderWidth = 2
        profileImageView.layer.borderColor = UIColor.white.cgColor
    }
    
    func configure(name: String) {
        greetingLabel.text = "Hello, \(name)!"
    }
    
    @IBAction func profileTapped(_ sender: UIButton) {
        print("Profile tapped!")
    }
}
