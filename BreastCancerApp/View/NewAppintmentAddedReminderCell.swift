
import UIKit

class NewAppintmentAddedReminderCell: UICollectionViewCell {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var deleteButton: UIButton!

    var onDelete: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configure(offset: ReminderOffset) {
        label.text = offset.rawValue
        label.font = .systemFont(ofSize: 15)
    }

    @IBAction func deleteTapped(_ sender: UIButton) {
        onDelete?()
    }
}
