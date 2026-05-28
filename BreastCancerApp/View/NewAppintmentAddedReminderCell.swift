import UIKit

class NewAppintmentAddedReminderCell: UICollectionViewCell {
    @IBOutlet var label: UILabel!
    @IBOutlet var deleteButton: UIButton!

    var onDelete: (() -> Void)?

    func configure(offset: ReminderOffset) {
        label.text = offset.rawValue
        label.font = .systemFont(ofSize: 15)
    }

    @IBAction func deleteTapped(_: UIButton) {
        onDelete?()
    }
}
