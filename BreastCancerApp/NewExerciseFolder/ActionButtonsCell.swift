import UIKit

class ActionButtonsCell: UICollectionViewCell {

    @IBOutlet weak var markAsDoneButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!

    var onMarkAsDone: (() -> Void)?
    var onNext: (() -> Void)?
    
    private(set) var isDone: Bool = false

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    @IBAction func markAsDoneTapped(_ sender: Any) {
        isDone.toggle()
        setDone(isDone)
        onMarkAsDone?()
    }

    @IBAction func nextTapped(_ sender: Any) {
        onNext?()
    }

    func setDone(_ done: Bool) {
        isDone = done
        if done {
            markAsDoneButton.setTitle("✓ Done", for: .normal)
        } else {
            markAsDoneButton.setTitle("Mark as Done", for: .normal)
        }
    }

    func setIsLastExercise(_ isLast: Bool) {
        nextButton.isHidden = isLast
    }
}
