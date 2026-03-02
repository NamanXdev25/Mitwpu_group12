//
//  OnboardingSelectionPickerCell.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 01/03/26.
//

import UIKit

class OnboardingSelectionPickerCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var placeholderLabel: UILabel!

    var onOptionSelected: ((String) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configure(title: String, fieldName: String, options: [String], selectedValue: String?) {
        titleLabel.text       = title
        placeholderLabel.text = selectedValue ?? fieldName

        let actions = options.map { option in
            UIAction(title: option,
                     state: option == selectedValue ? .on : .off) { [weak self] _ in
                self?.placeholderLabel.text = option
                self?.onOptionSelected?(option)
            }
        }

        if let cardView = contentView.subviews.first,
           let menuButton = cardView.subviews.compactMap({ $0 as? UIButton }).first {
            menuButton.menu = UIMenu(title: "", children: actions)
            menuButton.showsMenuAsPrimaryAction = true
        }
    }
}
