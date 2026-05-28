import UIKit

class RecentJournalCell: UICollectionViewCell {
    static let reuseIdentifier: String = "RecentJournalCell"

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var moreButton: UIButton!

    private var onEdit: ((JournalEntry) -> Void)?
    private var onDelete: ((JournalEntry) -> Void)?
    private var currentEntry: JournalEntry?

    override func awakeFromNib() {
        super.awakeFromNib()
        moreButton.showsMenuAsPrimaryAction = true
    }

    func formattedJournalDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")

        let thisYear = calendar.component(.year, from: Date())
        let entryYear = calendar.component(.year, from: date)

        if thisYear == entryYear {
            formatter.setLocalizedDateFormatFromTemplate("EEE, MMM d")
            return formatter.string(from: date)
        }

        formatter.setLocalizedDateFormatFromTemplate("MMM d, yyyy")
        return formatter.string(from: date)
    }

    func configure(
        with entry: JournalEntry,
        onEdit: ((JournalEntry) -> Void)? = nil,
        onDelete: ((JournalEntry) -> Void)? = nil
    ) {
        currentEntry = entry
        self.onEdit = onEdit
        self.onDelete = onDelete

        titleLabel.text = entry.title
        descriptionLabel.text = entry.content
        dateLabel.text = formattedJournalDate(entry.date)

        let edit = UIAction(title: "Edit", image: UIImage(systemName: "pencil")) { _ in
            onEdit?(entry)
        }

        let delete = UIAction(
            title: "Delete",
            image: UIImage(systemName: "trash"),
            attributes: .destructive
        ) { _ in
            onDelete?(entry)
        }

        moreButton.menu = UIMenu(children: [edit, delete])
    }
}
