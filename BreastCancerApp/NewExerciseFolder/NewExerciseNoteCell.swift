import UIKit

class NewExerciseNoteCell: UICollectionViewCell {
    @IBOutlet var noteLabel: UILabel!

    func configure(with note: String) {
        noteLabel.text = note
    }
}
