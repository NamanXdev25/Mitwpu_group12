//
//  HomeQuoteCell.swift
//  BreastCancerApp
//
//  Created by Naman Bhansali on 02/02/26.
//

import UIKit

class HomeQuoteCell: UICollectionViewCell {

    @IBOutlet weak var QuoteView: UIView!
    @IBOutlet weak var QuoteLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    // MARK: - Configure
    func configure(quote: String) {
        QuoteLabel.text = quote
    }
}
