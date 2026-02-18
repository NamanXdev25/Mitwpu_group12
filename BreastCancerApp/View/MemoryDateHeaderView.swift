import UIKit

final class MemoryDateHeaderView: UICollectionReusableView {

    static let reuseIdentifier = "MemoryDateHeaderView"

    @IBOutlet private weak var titleLabel: UILabel!

    private let calendar = Calendar.current

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = .label
    }

    func configure(with date: Date) {
        if calendar.isDateInToday(date) {
            titleLabel.text = "Today"
        } else if calendar.isDateInYesterday(date) {
            titleLabel.text = "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMMM yyyy"
            titleLabel.text = formatter.string(from: date)
        }
    }
}
