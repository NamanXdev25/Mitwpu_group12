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
        
    }
    
    // MARK: - Configure
    func configure(with suggestion: Suggestion) {
        SuggestionTitleLabel.text = suggestion.title
        SuggestionSubheadLabel.text = suggestion.subtitle
        
        // Set image with proper content mode
        SuggestionImageView.image = UIImage(named: suggestion.imageName)
    }
}
