//
//  HomeHealingGardenCell.swift
//  BreastCancerApp
//
//  Created by Naman Bhansali on 15/12/25.
//

import UIKit

class HomeHealingGardenCell: UICollectionViewCell {
    
    @IBOutlet weak var containerView: UIView!
    
    // Title
    @IBOutlet weak var titleLabel: UILabel!           // "Healing Garden"
    
    // Left Side Info
    @IBOutlet weak var pointsLabel: UILabel!          // "800"
    @IBOutlet weak var flowerLabel: UILabel!          // Flower icon/emoji
    @IBOutlet weak var levelLabel: UILabel!           // "to Level 2"
    
    @IBOutlet weak var ChevronButton: UIButton!
    // Progress Bar
    @IBOutlet weak var progressView: UIProgressView!
    
    // Right Side Stats
    @IBOutlet weak var currentProgressLabel: UILabel! // "5200"
    @IBOutlet weak var separatorLabel: UILabel!       // "/"
    @IBOutlet weak var totalGoalLabel: UILabel!       // "6000"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    @IBAction func ChevronTapped(_ sender: Any) {
    }
    
    
}
