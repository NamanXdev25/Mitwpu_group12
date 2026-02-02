////
////  HomeSuggestionCell.swift
////  BreastCancerApp
////
////  Created by Naman Bhansali on 03/02/26.
////
//
//import UIKit
//
//class HomeSuggestionCell: UICollectionViewCell {
//
//    @IBOutlet weak var SuggestionView: UIView!
//    @IBOutlet weak var SuggestionImageView: UIImageView!
//    @IBOutlet weak var SuggestionTitleLabel: UILabel!
//    @IBOutlet weak var SuggestionSubheadLabel: UILabel!
//    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        // Initialization code
//    }
//    
//    // MARK: - Configure
//    func configure(with suggestion: Suggestion) {
//        SuggestionTitleLabel.text = suggestion.title
//        SuggestionSubheadLabel.text = suggestion.subtitle
//        SuggestionImageView.image = UIImage(named: suggestion.imageName)
//    }
//}


//
//  HomeSuggestionCell.swift
//  BreastCancerApp
//
//  Created by Naman Bhansali on 03/02/26.
//

import UIKit

class HomeSuggestionCell: UICollectionViewCell {

    @IBOutlet weak var SuggestionView: UIView!
    @IBOutlet weak var SuggestionImageView: UIImageView!
    @IBOutlet weak var SuggestionTitleLabel: UILabel!
    @IBOutlet weak var SuggestionSubheadLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // CRITICAL FIX: Prevent image stretching
        setupImageView()
        setupCardAppearance()
    }
    
    private func setupImageView() {
        // Prevent stretching - maintain aspect ratio
        SuggestionImageView.contentMode = .scaleAspectFill
        SuggestionImageView.clipsToBounds = true
        
        // Optional: Add corner radius to image
        SuggestionImageView.layer.cornerRadius = 13
        SuggestionImageView.layer.masksToBounds = true
    }
    
    private func setupCardAppearance() {
        // Optional: Add card shadow and styling
        SuggestionView.layer.cornerRadius = 13
        SuggestionView.layer.shadowColor = UIColor.black.cgColor
        SuggestionView.layer.shadowOffset = CGSize(width: 0, height: 2)
        SuggestionView.layer.shadowRadius = 8
        SuggestionView.layer.shadowOpacity = 0.08
        SuggestionView.layer.masksToBounds = false
        
        // Ensure background is opaque for shadow to show
        SuggestionView.backgroundColor = .white
    }
    
    // MARK: - Configure
    func configure(with suggestion: Suggestion) {
        SuggestionTitleLabel.text = suggestion.title
        SuggestionSubheadLabel.text = suggestion.subtitle
        
        // Set image with proper content mode
        SuggestionImageView.image = UIImage(named: suggestion.imageName)
        SuggestionImageView.contentMode = .scaleAspectFill
    }
}
