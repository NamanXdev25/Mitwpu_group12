import UIKit

class EmotionPickerCell: UICollectionViewCell {
    @IBOutlet var cardView: UIView!
    @IBOutlet var happyStack: UIStackView!
    @IBOutlet var sadStack: UIStackView!
    @IBOutlet var anxiousStack: UIStackView!
    @IBOutlet var tiredStack: UIStackView!

    var didSelectEmotion: ((Int) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        happyStack.isUserInteractionEnabled = true
        sadStack.isUserInteractionEnabled = true
        anxiousStack.isUserInteractionEnabled = true
        tiredStack.isUserInteractionEnabled = true

        happyStack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(_:))))
        sadStack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(_:))))
        anxiousStack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(_:))))
        tiredStack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(_:))))
    }

    @objc private func handleTap(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view else { return }

        switch view {
        case happyStack:
            didSelectEmotion?(0)
        case sadStack:
            didSelectEmotion?(1)
        case anxiousStack:
            didSelectEmotion?(2)
        case tiredStack:
            didSelectEmotion?(3)
        default:
            break
        }
    }
}
