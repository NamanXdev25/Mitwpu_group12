//
//  JournalActionCell.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 25/11/25.
//

import UIKit

class JournalActionCell: UICollectionViewCell {

    static let reuseIdentifier = "JournalActionCell"
    
    var didTap: (() -> Void)?
    
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var chevronView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        chevronView.image = UIImage(systemName: "chevron.right")
        chevronView.tintColor = .systemGray3
    }
    
    func configure(title: String, subtitle: String, icon: UIImage) {
            titleLabel.text = title
            subtitleLabel.text = subtitle
            iconView.image = icon
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        didTap?()
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        didTap?()
    }

    

}
