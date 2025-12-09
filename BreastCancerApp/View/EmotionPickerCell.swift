//
//  EmotionPickerCell.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 09/12/25.
//
import UIKit

class EmotionPickerCell: UICollectionViewCell {
    // container card view
    @IBOutlet weak var cardView: UIView!

    // connect four buttons (or UIControls) and labels
    @IBOutlet weak var emotionButton0: UIButton!
    @IBOutlet weak var emotionButton1: UIButton!
    @IBOutlet weak var emotionButton2: UIButton!
    @IBOutlet weak var emotionButton3: UIButton!

    // callback to view controller
    var didSelectEmotion: ((Int) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()     

        // wire buttons to a common action
        emotionButton0.tag = 0
        emotionButton1.tag = 1
        emotionButton2.tag = 2
        emotionButton3.tag = 3

        emotionButton0.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        emotionButton1.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        emotionButton2.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        emotionButton3.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
    }

    @objc private func buttonTapped(_ sender: UIButton) {
        didSelectEmotion?(sender.tag)
    }
}
