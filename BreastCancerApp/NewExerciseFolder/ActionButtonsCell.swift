import UIKit

class ActionButtonsCell: UICollectionViewCell {

    @IBOutlet weak var markAsDoneButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!

    var onMarkAsDone: (() -> Void)?
    var onNext: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    @IBAction func markAsDoneTapped(_ sender: Any) {
        animateButton(markAsDoneButton)
        onMarkAsDone?()
    }

    @IBAction func nextTapped(_ sender: Any) {
        animateButton(nextButton)
        onNext?()
    }

    func animateButton(_ button: UIButton) {
        UIView.animate(withDuration: 0.1, animations: {
            button.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                button.transform = .identity
            }
        }
    }

    /// Call this to visually reflect whether the exercise is already marked done
    func setDone(_ done: Bool) {
        if done {
            markAsDoneButton.setTitle("✓ Done", for: .normal)
            markAsDoneButton.backgroundColor = .white
            let pink = UIColor(named: "plusbuttoncolor") ?? .systemPink
            markAsDoneButton.setTitleColor(pink, for: .normal)
            markAsDoneButton.layer.borderWidth = 1
            markAsDoneButton.layer.borderColor = pink.cgColor
        } else {
            let pink = UIColor(named: "plusbuttoncolor") ?? .systemPink
            markAsDoneButton.setTitle("Mark as Done", for: .normal)
            markAsDoneButton.backgroundColor = pink
            markAsDoneButton.setTitleColor(.white, for: .normal)
            markAsDoneButton.layer.borderWidth = 0
            markAsDoneButton.layer.borderColor = nil
        }
    }

    /// Hide the Next button on the last exercise
    func setIsLastExercise(_ isLast: Bool) {
        nextButton.isHidden = isLast
    }
}
