//
//  JournalSectionHeaderView.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 25/11/25.
//

import UIKit

class JournalSectionHeaderView: UICollectionReusableView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!

    static let reuseIdentifier = "header_cell"

    override func awakeFromNib() {
        super.awakeFromNib()

        actionButton.isHidden = true
        actionButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
    }

    func configure(title: String, showButton: Bool, buttonTitle: String = "See All") {
        titleLabel.text = title

        actionButton.isHidden = !showButton
        actionButton.setTitle(buttonTitle, for: .normal)
    }
}
