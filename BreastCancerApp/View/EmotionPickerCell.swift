//
//  EmotionPickerCell.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 09/12/25.
//

import UIKit

class EmotionPickerCell: UICollectionViewCell {

    @IBOutlet weak var cardView: UIView!

    // These are UIStackViews in your XIB
    @IBOutlet weak var happyStack: UIStackView!
    @IBOutlet weak var sadStack: UIStackView!
    @IBOutlet weak var anxiousStack: UIStackView!
    @IBOutlet weak var tiredStack: UIStackView!

    var didSelectEmotion: ((Int) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        // Enable touch
        happyStack.isUserInteractionEnabled = true
        sadStack.isUserInteractionEnabled = true
        anxiousStack.isUserInteractionEnabled = true
        tiredStack.isUserInteractionEnabled = true

        // Add gestures
        happyStack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(_:))))
        sadStack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(_:))))
        anxiousStack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(_:))))
        tiredStack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(_:))))
    }

    @objc private func handleTap(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view else { return }

        switch view {
        case happyStack:   didSelectEmotion?(0)
        case sadStack:     didSelectEmotion?(1)
        case anxiousStack: didSelectEmotion?(2)
        case tiredStack:   didSelectEmotion?(3)
        default: break
        }
    }
}
