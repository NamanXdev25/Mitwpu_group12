import UIKit

class ActionButtonsCell: UICollectionViewCell {
    @IBOutlet var markAsDoneButton: UIButton!
    @IBOutlet var nextButton: UIButton!

    var onMarkAsDone: (() -> Void)?
    var onNext: (() -> Void)?

    private(set) var isDone: Bool = false

    @IBAction func markAsDoneTapped(_: Any) {
        isDone.toggle()
        setDone(isDone)
        onMarkAsDone?()
    }

    @IBAction func nextTapped(_: Any) {
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
